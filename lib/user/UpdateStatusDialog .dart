import 'package:flutter/material.dart';
import 'package:flutter_provider/user/AppointmentStatus%20.dart';

class UpdateStatusDialog extends StatefulWidget {
  final AppointmentStatus currentStatus;
  final Function(AppointmentStatus) onStatusUpdated;

  const UpdateStatusDialog({
    required this.currentStatus,
    required this.onStatusUpdated,
  });

  @override
  _UpdateStatusDialogState createState() => _UpdateStatusDialogState();
}

class _UpdateStatusDialogState extends State<UpdateStatusDialog> {
  late AppointmentStatus selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.currentStatus;
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return (
        // backgroundColor: Color.fromARGB(0, 70, 212, 42),
        // insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        // contentPadding: EdgeInsets.zero,
        Container(
            constraints: BoxConstraints(maxWidth: 300),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blueAccent,
                width: 1.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogHeader(),
                _buildStatusOptions(),
                _buildDialogActions(isMobile: isMobile),
              ],
            )));
  }

  Widget _buildDialogHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ), // إضافة قوس إغلاق هنا
      child: Row(
        // تغيير Column إلى Row
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.update, size: 20, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text(
                "تحديث الحالة",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18),
            color: Colors.grey[400],
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOptions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusTile(
            status: AppointmentStatus.waiting,
            color: Colors.amber[600]!,
            icon: Icons.access_time,
            label: "في الانتظار",
          ),
          Divider(height: 8, thickness: 0.5, color: Colors.grey[700]),
          _buildStatusTile(
            status: AppointmentStatus.inProgress,
            color: Colors.blueAccent,
            icon: Icons.build,
            label: "قيد العمل",
          ),
          Divider(height: 8, thickness: 0.5, color: Colors.grey[700]),
          _buildStatusTile(
            status: AppointmentStatus.ready,
            color: Colors.greenAccent[400]!,
            icon: Icons.done_all,
            label: "جاهزة",
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTile({
    required AppointmentStatus status,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 2),
      dense: true,
      minLeadingWidth: 0,
      leading: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: selectedStatus == status ? color : Colors.white,
          fontWeight:
              selectedStatus == status ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: Radio<AppointmentStatus>(
        value: status,
        groupValue: selectedStatus,
        activeColor: color,
        onChanged: (value) => setState(() => selectedStatus = value!),
      ),
      onTap: () => setState(() => selectedStatus = status),
    );
  }

  Widget _buildDialogActions({required bool isMobile}) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text("إلغاء", style: TextStyle(fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onStatusUpdated(selectedStatus);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            child: Text(
              "تأكيد",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
