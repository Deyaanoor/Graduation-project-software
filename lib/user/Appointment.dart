// ------------------- Data Model -------------------
import 'package:flutter/material.dart';

class Appointment {
  final String id;
  final DateTime date;
  final TimeOfDay time;
  final String carModel;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String status;

  Appointment({
    required this.id,
    required this.date,
    required this.time,
    required this.carModel,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.status,
  });
}
