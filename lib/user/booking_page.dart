import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _formKey = GlobalKey<FormState>();
  final CalendarFormat _calendarFormat = CalendarFormat.month;

  List<DateTime> blockedDates = [
    DateTime.now().add(const Duration(days: 3)),
    DateTime.now().add(const Duration(days: 5)),
  ];

  List<TimeOfDay> blockedTimes = [
    const TimeOfDay(hour: 10, minute: 0),
    const TimeOfDay(hour: 11, minute: 0),
  ];

  final List<TimeOfDay> _allAvailableTimes = [
    const TimeOfDay(hour: 9, minute: 0),
    const TimeOfDay(hour: 10, minute: 0),
    const TimeOfDay(hour: 11, minute: 0),
    const TimeOfDay(hour: 12, minute: 0),
    const TimeOfDay(hour: 13, minute: 0),
    const TimeOfDay(hour: 14, minute: 0),
    const TimeOfDay(hour: 15, minute: 0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حجز موعد')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCalendar(),
            const SizedBox(height: 20),
            if (_selectedDate != null) _buildTimeSlots(),
            if (_selectedTime != null) _buildUserForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 30)),
        focusedDay: DateTime.now(),
        calendarFormat: _calendarFormat,
        availableCalendarFormats: const {
          CalendarFormat.month: 'شهري',
          CalendarFormat.week: 'أسبوعي'
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() => _selectedDate = selectedDay);
          _selectedTime = null;
        },
        selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
        enabledDayPredicate: (day) => !blockedDates.contains(day),
        calendarStyle: CalendarStyle(
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF00C2AB),
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
          outsideDaysVisible: false,
          todayTextStyle: const TextStyle(color: Colors.black),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    final availableTimes = _allAvailableTimes
        .where((time) => !blockedTimes.contains(time))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('الأوقات المتاحة:', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        if (availableTimes.isEmpty)
          const Text('لا توجد مواعيد متاحة لهذا اليوم.',
              style: TextStyle(color: Colors.red, fontSize: 16)),
        Wrap(
          spacing: 10,
          children: availableTimes.map((time) {
            final isSelected = time == _selectedTime;
            return ChoiceChip(
              label: Text(time.format(context)),
              selected: isSelected,
              onSelected: (selected) =>
                  setState(() => _selectedTime = selected ? time : null),
              backgroundColor:
                  isSelected ? const Color(0xFF00C2AB) : Colors.grey[200],
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildUserForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'الاسم الكامل',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) =>
                value!.isEmpty ? 'يرجى إدخال الاسم الكامل' : null,
          ),
          const SizedBox(height: 15),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'البريد الإلكتروني',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'يرجى إدخال البريد الإلكتروني';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'البريد الإلكتروني غير صحيح';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'رقم الهاتف',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value!.isEmpty) {
                return 'يرجى إدخال رقم الهاتف';
              }
              if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                return 'رقم الهاتف يجب أن يتكون من 10 أرقام';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C2AB),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Here you can handle the booking logic
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ConfirmationPage(),
                  ),
                );
              }
            },
            child: const Text('احجز الآن', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}

class ConfirmationPage extends StatelessWidget {
  const ConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تأكيد الحجز')),
      body: const Center(
        child: Text('تم الحجز بنجاح!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
