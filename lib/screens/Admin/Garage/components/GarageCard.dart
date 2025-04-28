import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/providers/garage_provider.dart';
import 'package:flutter_provider/screens/Admin/Garage/components/EditGaragePage.dart';
import 'package:flutter_provider/screens/Admin/Garage/GarageDetailsPage.dart';
import 'package:flutter_provider/widgets/AlertToDelete.dart';
import 'package:flutter_provider/widgets/CustomDialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GarageCard extends ConsumerStatefulWidget {
  final String name;
  final String location;
  final String id;
  const GarageCard(
      {required this.name, required this.location, required this.id});

  @override
  _GarageCardState createState() => _GarageCardState();
}

class _GarageCardState extends ConsumerState<GarageCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      hoverColor: Colors.orange.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 300,
        height: _isExpanded ? 250 : 200,
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.orange, width: 2),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.garage, color: Colors.orange, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(
                  color: Colors.grey,
                  height: 1,
                  thickness: 0.5,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.orange, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Location:',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.location,
                        style: TextStyle(
                          fontSize: 17.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
                if (_isExpanded) ...[
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.visibility,
                          label: 'View',
                          onPressed: () {
                            if (ResponsiveHelper.isDesktop(context)) {
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: SizedBox(
                                      width: 600,
                                      child: GarageDetailsPage(
                                          garageId: widget.id),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      GarageDetailsPage(garageId: widget.id),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 0.6,
                        color: Colors.grey[300],
                      ),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.edit,
                          label: 'Edit',
                          onPressed: () {
                            if (ResponsiveHelper.isDesktop(context)) {
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: SizedBox(
                                      width: 600,
                                      child:
                                          EditGaragePage(garageId: widget.id),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditGaragePage(garageId: widget.id),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 0.6,
                        color: Colors.grey[300],
                      ),
                      Expanded(
                        child: _deleteFunction(context),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _deleteFunction(BuildContext context) {
    return _buildActionButton(
      icon: Icons.delete,
      label: 'Delete',
      onPressed: () async {
        final confirm = await showDialog(
          context: context,
          builder: (_) => AlertToDelete(
            context: context,
            title: 'تأكيد الحذف',
            content: 'هل أنت متأكد أنك تريد حذف هذا الجراج؟',
          ),
        );

        if (confirm == true) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          try {
            final deleteGarage = ref.read(deleteGarageProvider);
            await deleteGarage(widget.id);

            Navigator.pop(context);
            ref.invalidate(garagesProvider);
            CustomDialogPage.show(
              context: context,
              type: MessageType.success,
              title: 'Success',
              content: 'تم حذف الجراج بنجاح',
            );
          } catch (e) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('فشل الحذف: $e')),
            );
          }
        }
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.orange,
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 17, color: Colors.orange[800]),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.orange[800],
            ),
          ),
        ],
      ),
    );
  }
}
