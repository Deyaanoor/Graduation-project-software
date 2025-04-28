import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/garage_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GarageDetailsPage extends ConsumerWidget {
  final String garageId;

  const GarageDetailsPage({required this.garageId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garageAsyncValue = ref.watch(garageByIdProvider(garageId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Garage Details'),
        backgroundColor: Colors.orange,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: garageAsyncValue.when(
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
          data: (garage) {
            final garageName = garage['name'] ?? 'غير متوفر';
            final ownerName = garage['ownerName'] ?? 'غير متوفر';
            final ownerEmail = garage['ownerEmail'] ?? 'غير متوفر';
            final location = garage['location'] ?? 'غير متوفر';

            print(
                'Garage Details: $garageName, $ownerName, $ownerEmail, $location');
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Garage Information'),
                _buildInfoCard(
                  icon: Icons.business,
                  title: 'Garage Name',
                  content: garageName,
                ),
                _buildInfoCard(
                  icon: Icons.person,
                  title: 'Owner Name',
                  content: ownerName,
                ),
                _buildInfoCard(
                  icon: Icons.email,
                  title: 'Owner Email',
                  content: ownerEmail,
                ),
                _buildInfoCard(
                  icon: Icons.location_on,
                  title: 'Location',
                  content: location,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Contact Owner',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
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
  }) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
    );
  }
}
