import 'package:flutter/material.dart';
import 'package:flutter_provider/screens/Admin/Employee/employee_screen.dart';
import 'package:flutter_provider/screens/Admin/reports_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Map<String, dynamic>> statsData = [
    {'value': '150', 'label': 'Cars Fixed', 'icon': Icons.directions_car},
    {'value': '\$25,000', 'label': 'Revenue', 'icon': Icons.attach_money},
    {'value': '18', 'label': 'Present Employees', 'icon': Icons.groups},
    {'value': '5', 'label': 'Unpaid Invoices', 'icon': Icons.warning},
  ];

  // Track selected card index for color change
  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange,
        title: Text(
          'Dashboard',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/profile.jpg'),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.orange),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/profile.jpg'),
                    radius: 40,
                  ),
                  SizedBox(height: 10),
                  Text('Admin',
                      style: GoogleFonts.poppins(
                          fontSize: 22, color: Colors.white)),
                ],
              ),
            ),
            _buildDrawerItem(Icons.home, 'Home'),
            _buildDrawerItem(Icons.person, 'Employees'),
            _buildDrawerItem(Icons.receipt_long, 'Invoices'),
            _buildDrawerItem(Icons.inventory, 'Inventory'),
            _buildDrawerItem(Icons.bar_chart, 'Reports'),
            _buildDrawerItem(Icons.settings, 'Settings'),
            _buildDrawerItem(Icons.help, 'Help'),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildNavigationCard('Employees', Icons.person, context, 0, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EmployeeScreen()),
              );
            }),
            _buildNavigationCard(
                'Invoices', Icons.receipt_long, context, 1, () {}),
            _buildNavigationCard(
                'Inventory', Icons.inventory, context, 2, () {}),
            _buildNavigationCard('Reports', Icons.bar_chart, context, 3, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReportsScreen()),
              );
            }),
            _buildNavigationCard('Settings', Icons.settings, context, 4, () {}),
            _buildNavigationCard('Help', Icons.help, context, 5, () {}),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Statistics'),
          BottomNavigationBarItem(
              icon: Icon(Icons.new_releases), label: 'Updates'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(title, style: GoogleFonts.poppins()),
      onTap: () {},
    );
  }

  Widget _buildNavigationCard(String title, IconData icon, BuildContext context,
      int index, VoidCallback? onClick) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index; // Update the selected index
        });
        onClick!();
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: _selectedIndex == index
              ? Colors.orange.withOpacity(0.7) // Change color on press
              : Colors.orange.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _selectedIndex == index
                  ? Colors.black.withOpacity(0.6)
                  : Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: Offset(6, 6),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 60, color: Colors.white),
              SizedBox(height: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
