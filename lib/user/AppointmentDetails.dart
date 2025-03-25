// ------------------- Appointment Details Dialog -------------------
import 'package:flutter/material.dart';
import 'package:flutter_provider/user/Appointment.dart';
import 'package:flutter_provider/user/maintest.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class AppointmentDetails extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetails({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.all(25),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 25),
              _buildDetailsList(context),
              const SizedBox(height: 25),
              _buildCloseButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.calendar_month_rounded,
            color: Colors.indigo.shade900,
            size: 30,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'تفاصيل الحجز',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.indigo.shade900,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsList(BuildContext context) {
    return Column(
      children: [
        _buildDetailItem(
          icon: Icons.date_range,
          title: 'التاريخ',
          value: DateFormat.yMMMd().format(appointment.date),
        ),
        const Divider(height: 40),
        _buildDetailItem(
          icon: Icons.access_time,
          title: 'الوقت',
          value: appointment.time.format(context),
        ),
        const Divider(height: 40),
        _buildDetailItem(
          icon: Icons.person,
          title: 'اسم صاحب المركبة',
          value: appointment.fullName,
        ),
        const Divider(height: 40),
        _buildDetailItem(
          icon: Icons.email,
          title: 'البريد الإلكتروني',
          value: appointment.email,
        ),
        const Divider(height: 40),
        _buildDetailItem(
          icon: Icons.phone,
          title: 'رقم الهاتف',
          value: appointment.phoneNumber,
        ),
        const Divider(height: 40),
        _buildDetailItem(
          icon: Icons.directions_car,
          title: 'اسم المركبة',
          value: appointment.carModel,
        ),
        const Divider(height: 40),
        StatusIndicator(
          status: appointment.status,
          color: _getStatusColor(appointment.status),
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.indigo.shade900),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.indigo.shade900,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => Navigator.pop(context),
        child: const Text(
          'إغلاق',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'معلق':
        return const Color(0xFFFFA726);
      case 'تم الحجز':
        return const Color(0xFF4CAF50);
      case 'ملغى':
        return const Color(0xFFEF5350);
      default:
        return Colors.grey;
    }
  }
}
