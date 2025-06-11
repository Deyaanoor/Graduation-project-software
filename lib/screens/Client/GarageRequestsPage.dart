import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/garage_provider.dart';
import 'package:flutter_provider/providers/home_provider.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_provider/providers/requestProvider.dart';
import 'package:flutter_provider/screens/Client/RequestDetailsPage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class GarageRequestsPage extends ConsumerStatefulWidget {
  const GarageRequestsPage({super.key});

  @override
  _GarageRequestsPageState createState() => _GarageRequestsPageState();
}

class _GarageRequestsPageState extends ConsumerState<GarageRequestsPage> {
  TextEditingController messageController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  String? currentLocation;
  String _searchQuery = '';
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    if (kIsWeb) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setState(() {
          currentLocation =
              "Lat: ${position.latitude}, Lng: ${position.longitude}";
        });
      } catch (e) {
        print("Error getting location: $e");
      }
    } else {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return Future.error('Location permission denied');
        }
      }

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentLocation =
            "Lat: ${position.latitude}, Lng: ${position.longitude}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userIdProvider).value;

    final garageId;

    // ref.watch(getGarageIdProvider(userId!)).value;
    final userInfo =
        userId != null ? ref.watch(getUserInfoProvider(userId)).value : null;

    final userRole =
        userInfo != null ? userInfo['role'] ?? 'بدون اسم' : 'جاري التحميل...';
    final lang = ref.watch(languageProvider);
    if (userRole == 'owner') {
      garageId = ref.watch(getGarageIdProvider(userId!)).value;
    } else {
      garageId = ref.watch(garageIdProvider);
    }
    final AsyncValue<List<Map<String, dynamic>>> requestsAsync;

    if (userRole == 'owner') {
      requestsAsync = ref.watch(getRequestsProvider(userId!));
    } else {
      requestsAsync = ref.watch(
        requestsByUserAndGarageProvider((userId: userId!, garageId: garageId!)),
      );
    }

    return Scaffold(
      body: requestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return Center(child: Text(lang['noRequests'] ?? 'لا توجد طلبات'));
          }

          final filteredRequests = _filterRequests(requests);
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final textColor = Theme.of(context).textTheme.bodyMedium?.color;
          final bgColor = Theme.of(context).cardColor;
          final dividerColor = isDark ? Colors.white12 : Colors.black12;

          return Column(
            children: [
              _buildFilters(lang),
              Expanded(
                child: Container(
                  width: ResponsiveHelper.isMobile(context)
                      ? MediaQuery.of(context).size.width // عرض كامل للموبايل
                      : MediaQuery.of(context).size.width * 0.4,
                  child: ListView.builder(
                    itemCount: filteredRequests.length + 1, // +1 for header
                    padding: const EdgeInsets.all(10),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Header row
                        return Container(
                          padding: const EdgeInsets.all(10),
                          color: Colors.orange.shade300,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  userRole == 'owner'
                                      ? (lang['name'] ?? 'Name')
                                      : (lang['requestNumber'] ?? 'رقم الطلب'),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                  flex: 3,
                                  child: Text(lang['date'] ?? 'Date',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              Expanded(
                                  flex: 2,
                                  child: Text(lang['status'] ?? 'Status',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              userRole == 'owner'
                                  ? Expanded(
                                      flex: 2,
                                      child: Text(lang['actions'] ?? 'Actions',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)))
                                  : const SizedBox(),
                            ],
                          ),
                        );
                      }

                      final request = filteredRequests[index - 1];

                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 8),
                            color: bgColor,
                            child: InkWell(
                              onTap: () => {
                                print("request: $request"),
                                print("userRole: $userRole"),
                                print("garageId: $garageId"),
                                // Navigate to details page
                                _navigateToDetails(request, userRole, garageId!)
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      userRole == 'owner'
                                          ? (request['userName'] ?? 'مجهول')
                                          : (index).toString(),
                                      style: TextStyle(color: textColor),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      _formatDate(request['timestamp']),
                                      style: TextStyle(color: textColor),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color:
                                            _getStatusColor(request['status']),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        request['status'],
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              color: Colors.orange),
                                          onPressed: () => _handleAction(
                                              'edit', request, lang),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () => _handleAction(
                                              'delete', request, lang),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(height: 1, thickness: 1, color: dividerColor),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'success':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildFilters(
    Map<String, dynamic> lang,
  ) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: lang['searchByUserName'] ?? 'بحث باسم المستخدم',
                    prefixIcon: const Icon(Icons.search, color: Colors.orange),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.orange),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.orange),
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange),
                ),
                child: DropdownButton<String>(
                  hint: Text(lang['filterByStatus'] ?? 'فلترة بالحالة'),
                  value: _selectedStatus,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.orange),
                  items: [
                    DropdownMenuItem(
                        value: 'pending',
                        child: Text(lang['pending'] ?? 'معلق')),
                    DropdownMenuItem(
                        value: 'success',
                        child: Text(lang['success'] ?? 'ناجح')),
                    DropdownMenuItem(
                        value: 'failed', child: Text(lang['failed'] ?? 'فشل')),
                  ],
                  onChanged: (value) => setState(() => _selectedStatus = value),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.date_range, color: Colors.orange),
                onPressed: () => _selectDateRange(context),
                tooltip: lang['selectDateRange'] ?? 'اختر نطاق تاريخي',
              ),
              if (_startDate != null || _endDate != null)
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.red),
                  onPressed: () => setState(() {
                    _startDate = null;
                    _endDate = null;
                  }),
                  tooltip: lang['clearFilter'] ?? 'مسح الفلترة',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddRequestDialog(
    String userId,
    String garageId,
    Map<String, dynamic> lang,
  ) async {
    return showDialog(
      context: context,
      builder: (context) {
        double dialogWidth = ResponsiveHelper.isMobile(context)
            ? double.infinity
            : MediaQuery.of(context).size.width * 0.6;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            width: dialogWidth, // تحديد العرض بناءً على الجهاز
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  lang['addNewRequest'] ?? 'إضافة طلب جديد',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    labelText: lang['message'] ?? 'الرسالة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 15),
                if (currentLocation != null)
                  TextField(
                    controller: locationController
                      ..text = currentLocation ?? '',
                    decoration: InputDecoration(
                      labelText: lang['location'] ?? 'الموقع',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                    ),
                    readOnly: true,
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(lang['cancel'] ?? 'إلغاء'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        final userInfo = userId != null
                            ? ref.watch(getUserInfoProvider(userId)).value
                            : null;

                        final userRole = userInfo != null
                            ? userInfo['role'] ?? 'بدون اسم'
                            : 'جاري التحميل...';
                        if (messageController.text.isNotEmpty) {
                          final newRequest = {
                            'userId': userId,
                            'garageId': garageId,
                            'message': messageController.text,
                            'location': locationController.text,
                            'timestamp': DateTime.now().toIso8601String(),
                            'status': 'معلق',
                          };

                          try {
                            Navigator.pop(context);
                            messageController.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(lang['requestAdded'] ??
                                    'تم إضافة الطلب بنجاح'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${lang['error'] ?? 'خطأ'}: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: Text(lang['save'] ?? 'حفظ',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _filterRequests(
      List<Map<String, dynamic>> requests) {
    return requests.where((request) {
      final garageId = request['garageId'];
      final userName = request['userName']?.toString().toLowerCase() ?? '';
      final status = request['status']?.toString();
      final timestamp = request['timestamp'] != null
          ? DateTime.parse(request['timestamp'])
          : null;

      if (_searchQuery.isNotEmpty &&
          !userName.contains(_searchQuery.toLowerCase())) {
        return false;
      }

      if (_selectedStatus != null && status != _selectedStatus) {
        return false;
      }

      if (_startDate != null &&
          timestamp != null &&
          timestamp.isBefore(_startDate!)) {
        return false;
      }

      if (_endDate != null &&
          timestamp != null &&
          timestamp.isAfter(_endDate!)) {
        return false;
      }

      return true;
    }).toList();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  String _formatDate(dynamic timestamp) {
    final date = DateTime.parse(timestamp.toString());
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _navigateToDetails(
      Map<String, dynamic> request, String userRole, String garageId) {
    print("inside navigateToDetails");
    ref.read(selectedRequestProvider.notifier).state = {
      ...request,
      'garageId': garageId,
    };
    userRole == 'owner'
        ? ref.read(selectedIndexProvider.notifier).state = 8
        : (ResponsiveHelper.isMobile(context))
            ? Navigator.push(context,
                MaterialPageRoute(builder: (context) => RequestDetailsPage()))
            : ref.read(selectedIndexProvider.notifier).state = 4;
  }

  void _handleAction(
    String action,
    Map<String, dynamic> request,
    Map<String, dynamic> lang,
  ) async {
    final List<String> statusOptions = ['pending', 'success'];
    final userId = ref.watch(userIdProvider).value;
    if (action == 'edit') {
      final newStatus = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(lang['updateStatus'] ?? 'تحديث الحالة'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: statusOptions.map((status) {
                return ListTile(
                  title: Text(status),
                  onTap: () => Navigator.pop(context, status),
                );
              }).toList(),
            ),
          );
        },
      );

      if (newStatus != null && newStatus != request['status']) {
        try {
          await ref.read(updateRequestStatusProvider)(
              request['_id'], newStatus);

          setState(() {
            request['status'] = newStatus;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(lang['statusUpdated'] ?? 'تم تحديث الحالة بنجاح')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(lang['statusUpdateFailed'] ?? 'فشل في تحديث الحالة')),
          );
        }
      }
    } else if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(lang['confirmDelete'] ?? 'تأكيد الحذف'),
          content: Text(
              lang['deleteRequestMsg'] ?? 'هل أنت متأكد من حذف هذا الطلب؟'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(lang['cancel'] ?? 'إلغاء')),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(lang['delete'] ?? 'حذف')),
          ],
        ),
      );

      if (confirm == true) {
        try {
          await ref.read(deleteRequestProvider)(request['_id']);

          ref.invalidate(getRequestsProvider(userId!));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(lang['deleted'] ?? 'تم الحذف بنجاح')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(lang['deleteFailed'] ?? 'فشل في الحذف')),
          );
        }
      }
    }
  }
}
