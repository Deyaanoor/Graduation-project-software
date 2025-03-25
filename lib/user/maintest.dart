import 'package:flutter/material.dart';
import 'package:flutter_provider/user/AppointmentsPage.dart';
import 'package:flutter_provider/user/DailySchedulePage.dart';
import 'package:flutter_provider/user/booking_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Care',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2A2E45),
        ),
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    BookingPage(),
    AppointmentsPage(),
    DailySchedulePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'الحجوزات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'حجوزاتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'الملف',
          ),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

// ------------------- Reusable Components -------------------
class IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final double? iconSize;
  final TextStyle? textStyle;

  const IconText({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
    this.iconSize = 20,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon,
            color: iconColor ?? Colors.blueGrey.shade400, size: iconSize),
        const SizedBox(width: 8),
        Text(text,
            style: textStyle ??
                TextStyle(
                  color: Colors.blueGrey.shade800,
                  fontSize: 15,
                )),
      ],
    );
  }
}

class StatusIndicator extends StatelessWidget {
  final String status;
  final Color color;

  const StatusIndicator({
    super.key,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
