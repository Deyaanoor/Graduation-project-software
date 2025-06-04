import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_provider/providers/language_provider.dart';

class UserProfileCard extends ConsumerWidget {
  final bool isExpanded;
  final Map<String, dynamic> userInfo;
  final bool isMobile;

  const UserProfileCard({
    Key? key,
    this.isExpanded = false,
    required this.userInfo,
    this.isMobile = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);

    String userName = userInfo['name'] ?? (lang['userName'] ?? 'User Name');
    String userEmail = userInfo['email'] ?? '';
    String userRole = userInfo['role']?.toString().toUpperCase() ??
        (lang['unknown'] ?? 'UNKNOWN');

    if (isMobile) {
      return UserAccountsDrawerHeader(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.orange[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        currentAccountPicture: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.orange, width: 2),
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            backgroundImage: (userInfo['avatar'] != null &&
                    userInfo['avatar'].toString().isNotEmpty)
                ? NetworkImage(userInfo['avatar'])
                : null,
            child: (userInfo['avatar'] == null ||
                    userInfo['avatar'].toString().isEmpty)
                ? const Icon(Icons.person, color: Colors.orange, size: 30)
                : null,
          ),
        ),
        accountName: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            userName,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        accountEmail: Text(
          userEmail,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      );
    }

    return isExpanded
        ? Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.orange,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: (userInfo['avatar'] != null &&
                          userInfo['avatar'].toString().isNotEmpty)
                      ? NetworkImage(userInfo['avatar'])
                      : null,
                  child: (userInfo['avatar'] == null ||
                          userInfo['avatar'].toString().isEmpty)
                      ? const Icon(Icons.person, size: 30, color: Colors.orange)
                      : null,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      userEmail,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${lang['role'] ?? 'Role'}: $userRole',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        : Center(
            child: CircleAvatar(
              radius: 30,
              backgroundImage: (userInfo['avatar'] != null &&
                      userInfo['avatar'].toString().isNotEmpty)
                  ? NetworkImage(userInfo['avatar'])
                  : null,
              child: (userInfo['avatar'] == null ||
                      userInfo['avatar'].toString().isEmpty)
                  ? const Icon(Icons.person, size: 30, color: Colors.orange)
                  : null,
            ),
          );
  }
}
