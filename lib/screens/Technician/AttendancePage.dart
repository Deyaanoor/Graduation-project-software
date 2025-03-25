import 'package:flutter/material.dart';
import 'package:flutter_provider/widgets/appbar.dart';
import 'package:table_calendar/table_calendar.dart';

class AttendanceSalaryPage extends StatefulWidget {
  const AttendanceSalaryPage({super.key});

  @override
  _AttendanceSalaryPageState createState() => _AttendanceSalaryPageState();
}

class _AttendanceSalaryPageState extends State<AttendanceSalaryPage> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  bool _isDesktop = false;

  Map<DateTime, String> attendanceDetails = {
    DateTime(2024, 3, 1): "8 ساعات عمل - بدون تأخير",
    DateTime(2024, 3, 5): "غياب",
    DateTime(2024, 3, 10): "6 ساعات عمل - تأخير ساعتين",
    DateTime(2024, 3, 15): "غياب",
    DateTime(2024, 3, 20): "8 ساعات عمل - بدون تأخير",
  };

  @override
  Widget build(BuildContext context) {
    _isDesktop = MediaQuery.of(context).size.width >= 1100;
    int workedDays = attendanceDetails.values
        .where((value) => !value.contains("غياب"))
        .length;

    return Scaffold(
      appBar: _isDesktop
          ? AppBar(
              title: Text("تفاصيل الحاضور والراتب"),
              backgroundColor: Colors.deepOrange,
              centerTitle: true,
            )
          : CustomAppBar(
              title: "تفاصيل الحاضور والراتب",
              backgroundColor: Colors.deepOrange,
            ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: _isDesktop ? 40 : 16,
          vertical: 20,
        ),
        child: _isDesktop
            ? _buildDesktopLayout(workedDays)
            : _buildMobileLayout(workedDays),
      ),
    );
  }

  Widget _buildDesktopLayout(int workedDays) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1400),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildCalendar(),
                  SizedBox(height: 30),
                  _buildWorkedDaysCard(workedDays),
                ],
              ),
            ),
            SizedBox(width: 40),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  if (attendanceDetails.containsKey(_selectedDay))
                    _buildAttendanceDetails(),
                  SizedBox(height: 30),
                  _buildSalaryCard(),
                  SizedBox(height: 30),
                  _buildDownloadButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(int workedDays) {
    return Column(
      children: [
        _buildCalendar(),
        SizedBox(height: 20),
        _buildWorkedDaysCard(workedDays),
        SizedBox(height: 20),
        if (attendanceDetails.containsKey(_selectedDay))
          _buildAttendanceDetails(),
        SizedBox(height: 20),
        _buildSalaryCard(),
        SizedBox(height: 20),
        _buildDownloadButton(),
      ],
    );
  }

  Widget _buildCalendar() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_isDesktop ? 20 : 12),
      ),
      child: Padding(
        padding: EdgeInsets.all(_isDesktop ? 20 : 12),
        child: TableCalendar(
          firstDay: DateTime.utc(2023, 1, 1),
          lastDay: DateTime.utc(2025, 12, 31),
          focusedDay: _selectedDay,
          calendarFormat: _calendarFormat,
          availableCalendarFormats: const {CalendarFormat.month: 'Month'},
          headerStyle: HeaderStyle(
            formatButtonVisible: _isDesktop,
            titleCentered: true,
            headerPadding: EdgeInsets.symmetric(vertical: _isDesktop ? 20 : 10),
            titleTextStyle: TextStyle(
              fontSize: _isDesktop ? 22 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(fontSize: _isDesktop ? 16 : 14),
            weekendStyle: TextStyle(fontSize: _isDesktop ? 16 : 14),
          ),
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() => _selectedDay = selectedDay);
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
            defaultTextStyle: TextStyle(
              fontSize: _isDesktop ? 18 : 14,
              color: Colors.black,
            ),
            weekendTextStyle: TextStyle(
              fontSize: _isDesktop ? 18 : 14,
              color: Colors.red,
            ),
            markerSize: _isDesktop ? 18 : 12,
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, date, _) {
              bool isAbsent = attendanceDetails.containsKey(date) &&
                  attendanceDetails[date] == "غياب";
              return Container(
                margin: EdgeInsets.all(_isDesktop ? 4 : 2),
                decoration: BoxDecoration(
                  color: isAbsent ? Colors.red[100] : Colors.transparent,
                  shape: BoxShape.circle,
                  border:
                      isAbsent ? Border.all(color: Colors.red, width: 2) : null,
                ),
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: _isDesktop ? 18 : 14,
                      color: isAbsent ? Colors.red[900] : Colors.black,
                      fontWeight:
                          isAbsent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWorkedDaysCard(int workedDays) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_isDesktop ? 16 : 12),
      ),
      child: Padding(
        padding: EdgeInsets.all(_isDesktop ? 24 : 16),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Colors.blue,
              size: _isDesktop ? 36 : 28,
            ),
            SizedBox(width: _isDesktop ? 20 : 10),
            Expanded(
              child: Text(
                "عدد الأيام التي تم العمل فيها: $workedDays يوم",
                style: TextStyle(
                  fontSize: _isDesktop ? 20 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceDetails() {
    return Card(
      elevation: 6,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_isDesktop ? 16 : 12),
      ),
      child: Padding(
        padding: EdgeInsets.all(_isDesktop ? 24 : 16),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              color: Colors.orange,
              size: _isDesktop ? 36 : 28,
            ),
            SizedBox(width: _isDesktop ? 20 : 10),
            Expanded(
              child: Text(
                "${attendanceDetails[_selectedDay]}",
                style: TextStyle(
                  fontSize: _isDesktop ? 20 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_isDesktop ? 20 : 12),
      ),
      child: Padding(
        padding: EdgeInsets.all(_isDesktop ? 28 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _salaryDetail("الراتب الأساسي", "500 دينار", Colors.black),
            _salaryDetail(
                "الحوافز", "+50 دينار (عمل إضافي)", Colors.green[700]!),
            _salaryDetail("الخصومات", "-20 دينار (تأخير)", Colors.red[700]!),
            Divider(thickness: 2, height: 40),
            Center(
              child: Text(
                "الراتب الصافي: 530 دينار",
                style: TextStyle(
                  fontSize: _isDesktop ? 26 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[900],
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _salaryDetail(String title, String amount, Color textColor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: _isDesktop ? 12 : 8),
      child: Row(
        children: [
          Icon(
            Icons.monetization_on,
            color: textColor,
            size: _isDesktop ? 32 : 24,
          ),
          SizedBox(width: _isDesktop ? 20 : 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: _isDesktop ? 20 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: _isDesktop ? 20 : 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton() {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(
        Icons.download,
        size: _isDesktop ? 32 : 24,
      ),
      label: Text(
        "تحميل إيصال الراتب",
        style: TextStyle(
          fontSize: _isDesktop ? 20 : 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          vertical: _isDesktop ? 18 : 12,
          horizontal: _isDesktop ? 40 : 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_isDesktop ? 12 : 8),
        ),
        elevation: 6,
        shadowColor: Colors.black54,
      ),
    );
  }
}
