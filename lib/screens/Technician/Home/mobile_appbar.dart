import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/notifications_provider.dart';
import 'package:flutter_provider/screens/auth/welcomePage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  final Map<String, dynamic> userInfo;

  const CustomAppBar({
    Key? key,
    required this.userInfo,
  }) : super(key: key);

  @override
  ConsumerState<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends ConsumerState<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userIdProvider).value;
    final unreadCountAsync = userId != null
        ? ref.watch(unreadCountProvider(userId))
        : const AsyncValue.data(0);

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
                    widget.userInfo['name'] ?? 'اسم الكراج',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),

                (widget.userInfo['role'] == 'owner' ||
                        widget.userInfo['role'] == 'employee')
                    ? IconButton(
                        icon: unreadCountAsync.when(
                          data: (unreadCount) => unreadCount > 0
                              ? Badge(
                                  label: Text(
                                    unreadCount.toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                  child: const Icon(Icons.notifications,
                                      color: Colors.white, size: 30),
                                )
                              : const Icon(Icons.notifications,
                                  color: Colors.white, size: 30),
                          loading: () => const Icon(Icons.notifications,
                              color: Colors.white, size: 30),
                          error: (err, stack) => const Icon(Icons.notifications,
                              color: Colors.white, size: 30),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/notifications');
                        },
                      )
                    : const SizedBox(),

                const SizedBox(width: 4),

                // Avatar
                _buildProfileMenu(context, widget.userInfo, ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 12);
}

Widget _buildProfileMenu(
    BuildContext context, Map<String, dynamic> userInfo, WidgetRef ref) {
  final avatarUrl = userInfo['avatar'];
  final hasAvatar = avatarUrl != null && avatarUrl.toString().isNotEmpty;

  return PopupMenuButton<String>(
    icon: Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: CircleAvatar(
        radius: 30,
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
          {
            ref.read(logoutProvider)();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WelcomePage()),
            );
          }
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
