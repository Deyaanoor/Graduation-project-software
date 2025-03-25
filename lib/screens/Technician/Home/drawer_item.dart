import 'package:flutter/material.dart';

Widget buildDrawerItem(
    BuildContext context, String title, IconData icon, Widget page) {
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    ),
  );
}
