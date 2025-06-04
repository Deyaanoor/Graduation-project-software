import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/home_provider.dart';
import 'package:flutter_provider/screens/Admin/Garage/ContactUsInboxPage.dart';
import 'package:flutter_provider/screens/Technician/settings/SettingsPage.dart';
import 'package:flutter_provider/screens/contactUs.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget buildDrawerItem(
  BuildContext context,
  WidgetRef ref,
  String title,
  IconData icon,
  int selectedIndex,
) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 5,
          offset: Offset(2, 2),
        ),
      ],
    ),
    child: ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(
        title,
        style: TextStyle(fontSize: 18.0, color: Colors.black87),
      ),
      onTap: () {
        if (selectedIndex == -1) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SettingsPage()));
        } else if (selectedIndex == -2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ContactUsPage()),
          );
        } else {
          ref.read(selectedIndexProvider.notifier).state = selectedIndex;
          Navigator.pop(context);
        }
      },
    ),
  );
}
