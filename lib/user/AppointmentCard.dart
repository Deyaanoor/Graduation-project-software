// ------------------- Main Appointment Card Component -------------------
import 'package:flutter/material.dart';
import 'package:flutter_provider/user/Appointment.dart';
import 'package:flutter_provider/user/maintest.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onDismissed;
  final VoidCallback onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onDismissed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(appointment.id),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      confirmDismiss: (_) => _confirmDismiss(context),
      onDismissed: (_) => onDismissed(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 3,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 80,
                decoration: BoxDecoration(
                  color: _getStatusColor(appointment.status),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderRow(context),
                    const SizedBox(height: 15),
                    IconText(
                      icon: Icons.access_time,
                      text: appointment.time.format(context),
                    ),
                    const SizedBox(height: 8),
                    IconText(
                      icon: Icons.person,
                      text: appointment.fullName,
                    ),
                    const SizedBox(height: 8),
                    IconText(
                      icon: Icons.directions_car,
                      text: appointment.carModel,
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

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 30),
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(Icons.delete_forever, color: Colors.white, size: 40),
    );
  }

  Future<bool> _confirmDismiss(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الإلغاء'),
        content: const Text('هل تريد حقًا إلغاء هذا الحجز؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('تراجع'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('نعم، ألغِ الحجز'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Row(
      children: [
        IconText(
          icon: Icons.date_range,
          text: DateFormat('EEE, d MMM').format(appointment.date),
          iconColor: Colors.indigo.shade900,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        StatusIndicator(
          status: appointment.status,
          color: _getStatusColor(appointment.status),
        ),
      ],
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
