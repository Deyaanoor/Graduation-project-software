import 'package:flutter/material.dart';
import 'package:flutter_provider/user/AppointmentStatus%20.dart';
import 'package:flutter_provider/user/Appointment_Card.dart';
import 'package:flutter_provider/user/UpdateStatusDialog%20.dart';
import 'package:intl/intl.dart';

class DailySchedulePage extends StatefulWidget {
  @override
  _DailySchedulePageState createState() => _DailySchedulePageState();
}

class _DailySchedulePageState extends State<DailySchedulePage> {
  List<Appointment> appointments = [
    Appointment(
      customerName: "أحمد محمد",
      phone: "+966500000000",
      email: "[email protected]",
      vehicleType: "سيارة سيدان",
      date: DateTime.now(),
      status: AppointmentStatus.inProgress,
    ),
    Appointment(
      customerName: "أحمد محمد",
      phone: "+966500000000",
      email: "[email protected]",
      vehicleType: "سيارة سيدان",
      date: DateTime.now(),
      status: AppointmentStatus.inProgress,
    ),
    Appointment(
      customerName: "أحمد محمد",
      phone: "+966500000000",
      email: "[email protected]",
      vehicleType: "سيارة سيدان",
      date: DateTime.now(),
      status: AppointmentStatus.inProgress,
    ),
  ];

  Appointment? selectedAppointment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("الجدول اليومي"),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;

          if (isMobile) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: appointments.length,
                    itemBuilder: (context, index) => AppointmentCard(
                      appointment: appointments[index],
                      onTap: () => _showAppointmentDetailsMobile(
                          context, appointments[index]),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Row(
              children: [
                Expanded(
                    flex: 2,
                    child: selectedAppointment != null
                        ? _buildAppointmentDetails()
                        : Center(child: Text("اختر حجزًا لعرض التفاصيل"))),
                Expanded(
                  flex: 3,
                  child: ListView.builder(
                    itemCount: appointments.length,
                    itemBuilder: (context, index) => AppointmentCard(
                      appointment: appointments[index],
                      onTap: () => setState(
                          () => selectedAppointment = appointments[index]),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  void _showAppointmentDetailsMobile(
      BuildContext context, Appointment appointment) {
    setState(() => selectedAppointment = appointment); // تحديث الحجز المحدد

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: _buildAppointmentDetailsMobile(appointment),
      ),
    );
  }

  Widget _buildAppointmentDetailsMobile(Appointment appointment) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(appointment.customerName, style: TextStyle(fontSize: 24)),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          _buildDetailRow(Icons.phone, appointment.phone),
          _buildDetailRow(Icons.email, appointment.email),
          _buildDetailRow(Icons.directions_car, appointment.vehicleType),
          _buildDetailRow(Icons.calendar_today,
              DateFormat('yyyy-MM-dd').format(appointment.date)),
          // في دالة _buildAppointmentDetailsMobile
          ElevatedButton(
            onPressed: () {
              // 1. إغلاق البوتوم شيت أولاً
              Navigator.pop(context);

              // 2. عرض الدايلوج بعد تأكيد الإغلاق
              Future.delayed(Duration(milliseconds: 100), () {
                if (mounted) {
                  // 3. التحقق من أن الويدجيت ما زال نشطًا
                  _showUpdateStatusDialog();
                }
              });
            },
            child: Text("تحديث الحالة"),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getStatusColor(appointment.status),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentDetails({bool isMobile = false}) {
    return Container(
      margin: isMobile ? EdgeInsets.zero : EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) // إضافة زر الإغلاق في الموبايل فقط
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(selectedAppointment!.customerName,
                    style: TextStyle(fontSize: 24)),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            )
          else
            Text(selectedAppointment!.customerName,
                style: TextStyle(fontSize: 24)),
          SizedBox(height: 16),
          _buildDetailRow(Icons.phone, selectedAppointment!.phone),
          _buildDetailRow(Icons.email, selectedAppointment!.email),
          _buildDetailRow(
              Icons.directions_car, selectedAppointment!.vehicleType),
          _buildDetailRow(Icons.calendar_today,
              DateFormat('yyyy-MM-dd').format(selectedAppointment!.date)),
          Spacer(),
          ElevatedButton(
            onPressed: () {
              _showUpdateStatusDialog();
              if (isMobile)
                Navigator.pop(context); // إغلاق الـ Popup بعد التحديث
            },
            child: Text("تحديث الحالة"),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getStatusColor(selectedAppointment!.status),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          SizedBox(width: 16),
          Text(text, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog() {
    final currentContext = context; // 4. حفظ الـ context الحالي

    showDialog(
      context: currentContext, // 5. استخدام الـ context المحفوظ
      builder: (context) {
        bool isMobile = MediaQuery.of(currentContext).size.width < 600;

        return Dialog(
          alignment: isMobile ? Alignment.center : null,
          insetPadding: isMobile
              ? EdgeInsets.symmetric(horizontal: 20, vertical: 50)
              : EdgeInsets.all(20),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isMobile
                  ? MediaQuery.of(currentContext).size.width * 0.9
                  : 400,
            ),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(15),
            ),
            child: UpdateStatusDialog(
              currentStatus: selectedAppointment?.status ??
                  AppointmentStatus.waiting, // 6. قيمة افتراضية
              onStatusUpdated: (newStatus) {
                if (mounted && selectedAppointment != null) {
                  // 7. تحقق مزدوج
                  setState(() => selectedAppointment!.status = newStatus);
                  _sendNotificationToCustomer();
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _sendNotificationToCustomer() {
    // إضافة كود إرسال الإشعار هنا (Firebase, API, etc.)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("تم إرسال الإشعار إلى العميل")),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.waiting:
        return Colors.orange;
      case AppointmentStatus.inProgress:
        return Colors.blue;
      case AppointmentStatus.ready:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
