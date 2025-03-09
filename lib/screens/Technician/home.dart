import 'package:flutter/material.dart';
import 'package:flutter_provider/screens/Technician/AttendancePage.dart';
import 'package:flutter_provider/screens/Technician/SparePartsPage.dart';
import 'package:flutter_provider/widgets/appbar.dart';
import 'package:flutter_provider/screens/Technician/report.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          title: 'العروض',
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        body: Text('Houses'),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1485290334039-a3c69043e517?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTYyOTU3NDE0MQ&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=300'),
                ),
                accountEmail: Text('jane.doe@example.com'),
                accountName: Text(
                  'Jane Doe',
                  style: TextStyle(fontSize: 24.0),
                ),
                decoration: BoxDecoration(
                  color: Colors.black87,
                ),
              ),
              itemInDrawer(context, 'Home', Icons.home, () {}, ReportPage()),
              itemInDrawer(
                  context, 'Reports', Icons.assignment, () {}, ReportPage()),
              itemInDrawer(context, 'Attendance record', Icons.calendar_today,
                  () {}, AttendanceSalaryPage()),
              itemInDrawer(
                  context, 'قطع الغيار', Icons.build, () {}, SparePartsApp()),
              itemInDrawer(context, ' الخريطة', Icons.map, () {}, ReportPage()),
              itemInDrawer(
                  context, 'شات مع الإدمن', Icons.chat, () {}, ReportPage()),
              itemInDrawer(
                  context, 'الإعدادات', Icons.settings, () {}, ReportPage()),
            ],
          ),
        ));
  }

  ListTile itemInDrawer(BuildContext context, String title, IconData icon,
      Function onTap, Widget page) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: TextStyle(fontSize: 24.0),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}
