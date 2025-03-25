import 'package:flutter/material.dart';
import 'package:flutter_provider/user/AppointmentStatus%20.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onTap;

  const AppointmentCard({required this.appointment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      color: Colors.grey[800],
      child: ListTile(
        onTap: onTap,
        leading: Icon(Icons.car_repair, color: Colors.blueAccent),
        title: Text(appointment.customerName),
        subtitle: Text(DateFormat('HH:mm').format(appointment.date)),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(appointment.status),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _getStatusText(appointment.status),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.waiting:
        return "في الانتظار";
      case AppointmentStatus.inProgress:
        return "قيد العمل";
      case AppointmentStatus.ready:
        return "جاهزة";
      default:
        return "";
    }
  }

  // في ملف appointment_card.dart
  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.waiting:
        return Colors.orange;
      case AppointmentStatus.inProgress:
        return Colors.blue;
      case AppointmentStatus.ready:
        return Colors.green;
      default:
        return Colors.grey; // اختياري لكن يُفضل
    }
  }
}

// في ملف appointment_card.dart
