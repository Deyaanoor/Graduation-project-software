import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/garage_provider.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_provider/providers/requestProvider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedRequestProvider =
    StateProvider<Map<String, dynamic>?>((ref) => null);

class RequestDetailsPage extends ConsumerStatefulWidget {
  const RequestDetailsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RequestDetailsPage> createState() => _RequestDetailsPageState();
}

class _RequestDetailsPageState extends ConsumerState<RequestDetailsPage> {
  late TextEditingController _controller;
  bool _showMessages = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = ref.watch(selectedRequestProvider);
    final lang = ref.watch(languageProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (request == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
            child: Text(
          lang['noRequestDetails'] ?? 'لا يوجد تفاصيل للطلب',
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        )),
      );
    }

    final garageId = request['garageId'];
    final garageAsync = ref.watch(garageByIdProvider(garageId));

    final isMobile = ResponsiveHelper.isMobile(context);

    return garageAsync.when(
      data: (garageData) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: _buildBody(
              context, garageData, request, ref, lang, theme, isDark),
        );
      },
      loading: () => Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: const Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Center(
              child: Text(
            lang['failedToLoadGarage'] ?? 'فشل تحميل بيانات الكراج',
            style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          ))),
    );
  }

  Widget _buildBody(
      BuildContext context,
      Map<String, dynamic> garageData,
      Map<String, dynamic> request,
      WidgetRef ref,
      Map<String, dynamic> lang,
      ThemeData theme,
      bool isDark) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [Colors.grey[900]!, Colors.grey[850]!]
              : [Colors.blue.shade50, Colors.white],
        ),
      ),
      child: isDesktop
          ? _buildDesktopLayout(request, garageData, ref, lang, theme, isDark)
          : _buildMobileLayout(request, garageData, ref, lang, theme, isDark),
    );
  }

  Widget _buildDesktopLayout(
      Map<String, dynamic> request,
      Map<String, dynamic> garageData,
      WidgetRef ref,
      Map<String, dynamic> lang,
      ThemeData theme,
      bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: _buildMap(request, garageData),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
              flex: 1,
              child: _buildMessage(
                  request['_id'], true, ref, lang, theme, isDark)),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
    Map<String, dynamic> request,
    Map<String, dynamic> garageData,
    WidgetRef ref,
    Map<String, dynamic> lang,
    ThemeData theme,
    bool isDark,
  ) {
    return Column(
      children: [
        SizedBox(
          height: 30,
        ),
        // الخريطة تأخذ 30% من الشاشة
        Flexible(
          flex: 3,
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(16), // يمكنك تغيير القيمة حسب رغبتك
                child: _buildMap(request, garageData),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _showMessages = !_showMessages;
              });
            },
            icon: Icon(_showMessages ? Icons.visibility_off : Icons.visibility),
            label: Text(_showMessages
                ? (lang['hideMessages'] ?? 'إخفاء الرسائل')
                : (lang['showMessages'] ?? 'عرض الرسائل')),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              // padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // الرسائل تأخذ 70% من الشاشة
        if (_showMessages)
          Flexible(
            flex: 7,
            child:
                _buildMessage(request['_id'], false, ref, lang, theme, isDark),
          ),
      ],
    );
  }

  Widget _buildMap(
      Map<String, dynamic> request, Map<String, dynamic> garageData) {
    // طلب
    Map<String, dynamic> requestLocation = {};
    try {
      requestLocation = json.decode(request['location']);
      print('موقع الطلب: $requestLocation');
    } catch (e) {
      print('فشل فك تشفير موقع الطلب: $e');
    }

    double requestLat =
        double.tryParse(requestLocation['latitude']?.toString() ?? '') ?? 0.0;
    double requestLng =
        double.tryParse(requestLocation['longitude']?.toString() ?? '') ?? 0.0;

    // كراج
    Map<String, dynamic> garageLocation = {};
    try {
      garageLocation = json.decode(garageData['location']);
      print('موقع الكراج: $garageLocation');
    } catch (e) {
      print('فشل فك تشفير موقع الكراج: $e');
    }

    double garageLat =
        double.tryParse(garageLocation['latitude']?.toString() ?? '') ?? 0.0;
    double garageLng =
        double.tryParse(garageLocation['longitude']?.toString() ?? '') ?? 0.0;

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(requestLat, requestLng),
        initialZoom: 14.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(requestLat, requestLng),
              width: 50,
              height: 50,
              child:
                  const Icon(Icons.location_pin, color: Colors.red, size: 50),
            ),
            Marker(
              point: LatLng(garageLat, garageLng),
              width: 40,
              height: 40,
              child:
                  const Icon(Icons.location_pin, color: Colors.blue, size: 40),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessage(String requestId, bool isDesktop, WidgetRef ref,
      Map<String, dynamic> lang, ThemeData theme, bool isDark) {
    final userId = ref.watch(userIdProvider).value;
    final userInfo =
        userId != null ? ref.watch(getUserInfoProvider(userId)).value : null;

    final messagesAsync = ref.watch(messagesStreamProvider(requestId));

    if (messagesAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (messagesAsync.hasError) {
      return Center(
          child: Text(
        lang['errorFetchingMessages'] ?? 'خطأ في جلب الرسائل',
        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      ));
    }

    final messages = messagesAsync.value ?? [];

    return Container(
      margin: EdgeInsets.all(isDesktop ? 0 : 16),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(15),
        color: theme.cardColor,
        child: Column(
          children: [
            SizedBox(
              height: isDesktop ? 350 : 300,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isDesktop ? 24 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isDesktop)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          lang['requestDetails'] ?? 'تفاصيل الطلب',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ListView.builder(
                      itemCount: messages.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isUser = msg['sender'] == 'user';

                        return Container(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            crossAxisAlignment: isUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? (isDark
                                          ? Colors.orange.shade900
                                          : const Color.fromARGB(
                                              255, 240, 160, 41))
                                      : (isDark
                                          ? Colors.orange.shade700
                                          : const Color.fromARGB(
                                              255, 245, 217, 63)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  msg['message'] ?? '',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 16 : 14,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                msg['timestamp']
                                        ?.toString()
                                        ?.substring(0, 16) ??
                                    '',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: lang['writeReplyHere'] ?? 'اكتب ردك هنا...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        fillColor: theme.inputDecorationTheme.fillColor,
                      ),
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.orange),
                    tooltip: lang['send'] ?? 'إرسال',
                    onPressed: () async {
                      final messageText = _controller.text.trim();
                      if (messageText.isEmpty) return;

                      final sender =
                          (userInfo != null && userInfo['role'] == 'owner')
                              ? "owner"
                              : "user";

                      await ref.read(addMessageToRequestProvider)(
                        requestId,
                        {
                          "sender": sender,
                          "message": messageText,
                        },
                      );

                      _controller.clear();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static LatLng _extractLatLng(String location) {
    try {
      final matches =
          RegExp(r'Lat:\s*([\d.]+),\s*Lng:\s*([\d.]+)').firstMatch(location);
      if (matches != null && matches.groupCount == 2) {
        return LatLng(
          double.parse(matches.group(1)!),
          double.parse(matches.group(2)!),
        );
      }
    } catch (e) {
      print('خطأ في تحويل الموقع: $e');
    }
    return const LatLng(0.0, 0.0);
  }
}
