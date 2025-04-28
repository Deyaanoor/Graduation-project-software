import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/widgets/CustomDialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showEditDialog(
  BuildContext context,
  String field,
  String key,
  String currentValue,
  bool isMobile,
  String userId,
  WidgetRef ref,
) {
  final TextEditingController controller =
      TextEditingController(text: currentValue);
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isPassword = field.toLowerCase() == 'password';

  // ✅ نقل متغيرات الرؤية هنا حتى تبقى محفوظة في الذاكرة
  bool obscureTextNew = true;
  bool obscureTextConfirm = true;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.all(isMobile ? 20 : 30),
          titlePadding: EdgeInsets.all(isMobile ? 20 : 30),
          title: Text(
            'تعديل $field',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.orange.shade800,
              fontSize: isMobile ? 20 : 24,
            ),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: isMobile ? null : 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isPassword) ...[
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: obscureTextNew,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        labelText: 'كلمة مرور جديدة',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelStyle: TextStyle(
                          color: Colors.orange.shade800,
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 18,
                        ),
                        filled: true,
                        fillColor: Colors.orange.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(isMobile ? 15 : 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureTextNew
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.orange.shade600,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureTextNew = !obscureTextNew;
                            });
                          },
                        ),
                      ),
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: obscureTextConfirm,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        labelText: 'تأكيد كلمة المرور',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelStyle: TextStyle(
                          color: Colors.orange.shade800,
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 18,
                        ),
                        filled: true,
                        fillColor: Colors.orange.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(isMobile ? 15 : 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureTextConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.orange.shade600,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureTextConfirm = !obscureTextConfirm;
                            });
                          },
                        ),
                      ),
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        color: Colors.black,
                      ),
                    ),
                  ] else ...[
                    TextFormField(
                      controller: controller,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        labelText: field,
                        labelStyle: TextStyle(
                          color: Colors.orange.shade800,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        filled: true,
                        fillColor: Colors.orange.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(isMobile ? 15 : 20),
                      ),
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actionsPadding: EdgeInsets.only(
            bottom: isMobile ? 15 : 20,
            left: isMobile ? 20 : 30,
            right: isMobile ? 20 : 30,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 15 : 25,
                      vertical: isMobile ? 10 : 15,
                    ),
                    backgroundColor: Colors.red.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'إلغاء',
                    style: TextStyle(
                      color: Colors.red.shade800,
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (isPassword) {
                      if (newPasswordController.text !=
                          confirmPasswordController.text) {
                        CustomDialogPage.show(
                          context: context,
                          type: MessageType.error,
                          title: 'Error',
                          content: 'passwords do not match',
                        );
                        return;
                      } else {
                        final userData = {
                          'userId': userId,
                          key: newPasswordController.text,
                        };
                        try {
                          await ref
                              .read(updateUserInfoProvider(userData).future);
                          ref.invalidate(getUserInfoProvider(userId));
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('تم التحديث بنجاح ✅')),
                          );
                        } catch (e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('حدث خطأ أثناء التحديث: $e')),
                          );
                        }
                      }
                    } else {
                      if (controller.text != currentValue) {
                        final userData = {
                          'userId': userId,
                          key: controller.text,
                        };
                        try {
                          await ref
                              .read(updateUserInfoProvider(userData).future);
                          ref.invalidate(getUserInfoProvider(userId));
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('تم التحديث بنجاح ✅')),
                          );
                        } catch (e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('حدث خطأ أثناء التحديث: $e')),
                          );
                        }
                      } else {
                        Navigator.pop(context);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 15 : 25,
                      vertical: isMobile ? 10 : 15,
                    ),
                    backgroundColor: Colors.orange.shade800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'تحديث',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}
