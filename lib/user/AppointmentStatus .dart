enum AppointmentStatus { waiting, inProgress, ready }

class Appointment {
  final String customerName;
  final String phone;
  final String email;
  final String vehicleType;
  final DateTime date;
  AppointmentStatus status;

  Appointment({
    required this.customerName,
    required this.phone,
    required this.email,
    required this.vehicleType,
    required this.date,
    required this.status,
  });
}
