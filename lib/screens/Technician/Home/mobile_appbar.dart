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
        height: preferredSize.height * 1.2,
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
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                // Menu Icon
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 24),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(maxWidth: 40),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),

                const SizedBox(width: 4),

                // العنوان بحجم كبير
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          text: 'Mechanic',
                          style: TextStyle(
                            fontSize: 26, // حجم كبير جداً
                            fontWeight: FontWeight.w900, // سميك أكثر
                            color: Color(0xffe46b10),
                            shadows: [
                              Shadow(
                                blurRadius: 2,
                                color: Colors.black26,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                          children: [
                            TextSpan(
                              text: 'Workshop',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 26, // نفس الحجم الكبير
                                fontWeight: FontWeight.w900, // سميك أكثر
                                shadows: [
                                  Shadow(
                                    blurRadius: 2,
                                    color: Colors.black26,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // مجموعة الإشعارات والصورة
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // أيقونة الإشعارات
                    if (widget.userInfo['role'] == 'owner' ||
                        widget.userInfo['role'] == 'employee' ||
                        widget.userInfo['role'] == 'admin')
                      Padding(
                        padding: const EdgeInsets.only(right: 0),
                        child: IconButton(
                          icon: unreadCountAsync.when(
                            data: (unreadCount) => unreadCount > 0
                                ? Badge(
                                    label: Text(
                                      unreadCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                    backgroundColor: Colors.red,
                                    child: const Icon(Icons.notifications,
                                        color: Colors.white, size: 24),
                                  )
                                : const Icon(Icons.notifications,
                                    color: Colors.white, size: 24),
                            loading: () => const Icon(Icons.notifications,
                                color: Colors.white, size: 24),
                            error: (err, stack) => const Icon(
                                Icons.notifications,
                                color: Colors.white,
                                size: 24),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(maxWidth: 40),
                          onPressed: () {
                            Navigator.pushNamed(context, '/notifications');
                          },
                        ),
                      ),

                    // صورة الملف الشخصي
                    _buildProfileMenu(context, widget.userInfo, ref),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

Widget _buildProfileMenu(
    BuildContext context, Map<String, dynamic> userInfo, WidgetRef ref) {
  final avatarUrl = userInfo['avatar'];
  final hasAvatar = avatarUrl != null && avatarUrl.toString().isNotEmpty;

  return PopupMenuButton<String>(
    padding: EdgeInsets.zero,
    icon: Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.orange, width: 1.5),
      ),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.white,
        backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
        child: !hasAvatar
            ? const Icon(Icons.person, size: 24, color: Colors.orange)
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
              MaterialPageRoute(builder: (context) => const WelcomePage(fromLogout: true)),
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
