import 'package:flutter/material.dart';
import 'package:flutter_provider/widgets/appbar.dart';
import 'package:table_calendar/table_calendar.dart';

class AttendanceSalaryPage extends StatefulWidget {
  const AttendanceSalaryPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AttendanceSalaryPageState createState() => _AttendanceSalaryPageState();
}

class _AttendanceSalaryPageState extends State<AttendanceSalaryPage> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();

  Map<DateTime, String> attendanceDetails = {
    DateTime(2024, 3, 1): "8 ساعات عمل - بدون تأخير",
    DateTime(2024, 3, 5): "غياب",
    DateTime(2024, 3, 10): "6 ساعات عمل - تأخير ساعتين",
    DateTime(2024, 3, 15): "غياب",
    DateTime(2024, 3, 20): "8 ساعات عمل - بدون تأخير",
  };

  @override
  Widget build(BuildContext context) {
    // حساب عدد الأيام التي تم العمل فيها
    int workedDays = attendanceDetails.values
        .where((value) => !value.contains("غياب"))
        .length;

    return Scaffold(
      appBar: CustomAppBar(
        title: "تفاصيل الحضور والراتب",
        backgroundColor: Colors.deepOrange,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // التقويم
            Card(
              elevation: 6,
              shadowColor: Colors.black54,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: TableCalendar(
                  firstDay: DateTime.utc(2023, 1, 1),
                  lastDay: DateTime.utc(2025, 12, 31),
                  focusedDay: _selectedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.deepOrange,
                      shape: BoxShape.circle,
                    ),
                    // تمييز أيام الغياب باللون الأحمر
                    defaultTextStyle: TextStyle(color: Colors.black),
                    outsideTextStyle: TextStyle(color: Colors.grey),
                    markerDecoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, date, _) {
                      bool isAbsent = attendanceDetails.containsKey(date) &&
                          attendanceDetails[date] == "غياب";
                      return Center(
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: isAbsent ? Colors.red : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                color: isAbsent ? Colors.white : Colors.black,
                                fontWeight: isAbsent
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // عدد أيام العمل
            itemCart(workedDays),

            SizedBox(height: 20),

            // تفاصيل الحضور
            if (attendanceDetails.containsKey(_selectedDay))
              Card(
                elevation: 5,
                shadowColor: Colors.black54,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.orange, size: 28),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "${attendanceDetails[_selectedDay]}",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 20),

            // معلومات الراتب
            Card(
              elevation: 6,
              shadowColor: Colors.black54,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _salaryDetail("الراتب الأساسي", "500 دينار", Colors.black),
                    _salaryDetail(
                        "الحوافز", "+50 دينار (عمل إضافي)", Colors.green),
                    _salaryDetail("الخصومات", "-20 دينار (تأخير)", Colors.red),
                    Divider(thickness: 1.2),
                    Center(
                      child: Text(
                        "الراتب الصافي: 530 دينار",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // زر تحميل إيصال الراتب
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.download, size: 24),
              label: Text("تحميل إيصال الراتب",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 5,
                shadowColor: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Card itemCart(int workedDays) {
    return Card(
      elevation: 5,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.blue, size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "عدد الأيام التي تم العمل فيها: $workedDays يوم",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت فرعية لعرض تفاصيل الراتب
  Widget _salaryDetail(String title, String amount, Color textColor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.monetization_on, color: textColor, size: 22),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          ),
        ],
      ),
    );
  }
}
