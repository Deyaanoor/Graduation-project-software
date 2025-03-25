// ------------------- Main Page Implementation -------------------
import 'package:flutter/material.dart';
import 'package:flutter_provider/user/Appointment.dart';
import 'package:flutter_provider/user/AppointmentCard.dart';
import 'package:flutter_provider/user/AppointmentDetails.dart';
import 'package:flutter_provider/user/maintest.dart';

class AppointmentsPage extends StatelessWidget {
  AppointmentsPage({super.key});

  final List<Appointment> appointments = [
    Appointment(
      id: '1',
      date: DateTime.now().add(const Duration(days: 1)),
      time: const TimeOfDay(hour: 10, minute: 0),
      carModel: 'Toyota Camry',
      fullName: 'محمد أحمد',
      email: 'mohamed@example.com',
      phoneNumber: '0551234567',
      status: 'معلق',
    ),
  ];

  void _handleDismiss(String id) {
    // Add your dismissal logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حجوزاتي'),
        backgroundColor: Colors.indigo.shade900,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFE8F4F8)],
          ),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          separatorBuilder: (_, i) => const SizedBox(height: 15),
          itemCount: appointments.length,
          itemBuilder: (context, index) => AppointmentCard(
            appointment: appointments[index],
            onDismissed: () => _handleDismiss(appointments[index].id),
            onTap: () => showDialog(
              context: context,
              builder: (_) =>
                  AppointmentDetails(appointment: appointments[index]),
            ),
          ),
        ),
      ),
    );
  }
}
