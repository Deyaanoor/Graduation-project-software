import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/garage_provider.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_provider/screens/map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class GarageDetailsPage extends ConsumerWidget {
  final String garageId;

  const GarageDetailsPage({required this.garageId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garageAsyncValue = ref.watch(garageByIdProvider(garageId));
    final lang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang['garageDetails'] ?? 'Garage Details'),
        backgroundColor: Colors.orange,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: garageAsyncValue.when(
            loading: () => Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                Center(child: Text('${lang['error'] ?? 'Error'}: $error')),
            data: (garage) {
              final garageName =
                  garage['name'] ?? (lang['notAvailable'] ?? 'غير متوفر');
              final ownerName = garage['owner']['name'] ??
                  (lang['notAvailable'] ?? 'غير متوفر');
              final ownerEmail = garage['owner']['email'] ??
                  (lang['notAvailable'] ?? 'غير متوفر');
              final location =
                  garage['location'] ?? (lang['notAvailable'] ?? 'غير متوفر');
              final ownerPhone = garage['owner']['phoneNumber'] ??
                  (lang['notAvailable'] ?? 'غير متوفر');
              final startSub = garage['subscriptionStartDate'];
              final endSub = garage['subscriptionEndDate'];

              String startformattedDate = lang['notAvailable'] ?? 'غير متوفر';
              String endformattedDate = lang['notAvailable'] ?? 'غير متوفر';

              if (startSub != null &&
                  startSub is String &&
                  startSub.isNotEmpty) {
                try {
                  DateTime startDateTime = DateTime.parse(startSub);
                  startformattedDate =
                      DateFormat('dd/MM/yyyy').format(startDateTime);
                } catch (e) {
                  print('خطأ في تنسيق تاريخ البداية: $e');
                }
              }

              if (endSub != null && endSub is String && endSub.isNotEmpty) {
                try {
                  DateTime endDateTime = DateTime.parse(endSub);
                  endformattedDate =
                      DateFormat('dd/MM/yyyy').format(endDateTime);
                } catch (e) {
                  print('خطأ في تنسيق تاريخ النهاية: $e');
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(
                      lang['garageInformation'] ?? 'Garage Information'),
                  _buildInfoCard(
                    icon: Icons.business,
                    title: lang['garageName'] ?? 'Garage Name',
                    content: garageName,
                  ),
                  _buildInfoCard(
                    icon: Icons.person,
                    title: lang['ownerName'] ?? 'Owner Name',
                    content: ownerName,
                  ),
                  _buildInfoCard(
                    icon: Icons.email,
                    title: lang['ownerEmail'] ?? 'Owner Email',
                    content: ownerEmail,
                  ),
                  _buildInfoCard(
                      icon: Icons.location_on,
                      title: lang['location'] ?? 'Location',
                      content: location,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  FreeMapPickerPage(initialLocation: location)),
                        );
                      }),
                  _buildInfoCard(
                    icon: Icons.phone,
                    title: lang['phoneNumber'] ?? 'Phone Number',
                    content: ownerPhone,
                  ),
                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    title: lang['subscriptionDate'] ?? 'Subscription date',
                    content: startformattedDate.isNotEmpty
                        ? startformattedDate
                        : (lang['notAvailable'] ?? 'غير متوفر'),
                  ),
                  _buildInfoCard(
                    icon: Icons.calendar_month,
                    title:
                        lang['subscriptionEndDate'] ?? 'Subscription end date',
                    content: endformattedDate.isNotEmpty
                        ? endformattedDate
                        : (lang['notAvailable'] ?? 'غير متوفر'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.orange[800],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    VoidCallback? onTap, // <- optional onTap
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.orange, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.orange,
                size: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
