import 'package:flutter/material.dart';
import 'package:flutter_provider/screens/auth/welcomePage.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Map<String, dynamic> userInfo;

  const CustomAppBar({Key? key, required this.userInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      shadowColor: Colors.orange.withOpacity(0.4),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: Container(
        height: preferredSize.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF9800), Color(0xFFFFC107)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Menu Icon
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 26),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),

                const SizedBox(width: 8),

                // Title
                Expanded(
                  child: Text(
                    userInfo['name'] ?? 'اسم الكراج',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),

                (userInfo['role'] == 'owner')
                    ? IconButton(
                        icon: const Icon(Icons.notifications_none,
                            color: Colors.white, size: 26),
                        onPressed: () {
                          Navigator.pushNamed(context, '/notifications');
                        },
                      )
                    : const SizedBox(),

                const SizedBox(width: 4),

                // Avatar
                _buildProfileMenu(context, userInfo),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 12);
}

Widget _buildProfileMenu(BuildContext context, Map<String, dynamic> userInfo) {
  final avatarUrl = userInfo['avatar'];
  final hasAvatar = avatarUrl != null && avatarUrl.toString().isNotEmpty;

  return PopupMenuButton<String>(
    icon: Container(
      width: 50, // لازم يكون أكبر شوي من الـ CircleAvatar
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.white,
        backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
        child: !hasAvatar
            ? const Icon(Icons.person, size: 28, color: Colors.orange)
            : null,
      ),
    ),
    onSelected: (value) {
      switch (value) {
        case 'Profile':
          Navigator.pushNamed(context, '/profile');
          break;
        case 'Settings':
          Navigator.pushNamed(context, '/settings');
          break;
        case 'Logout':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WelcomePage()),
          );
          break;
      }
    },
    itemBuilder: (BuildContext context) => const [
      PopupMenuItem<String>(
        value: 'Profile',
        child: Text('Profile'),
      ),
      PopupMenuItem<String>(
        value: 'Settings',
        child: Text('Settings'),
      ),
      PopupMenuItem<String>(
        value: 'Logout',
        child: Text('Logout'),
      ),
    ],
  );
}
