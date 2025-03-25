import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AccountSettingsPage extends StatefulWidget {
  @override
  _AccountSettingsPageState createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  File? _selectedImage;
  XFile? _pickedFile;

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (kIsWeb ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        // Desktop & Web Handling (المعدل)
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowCompression: true,
        );

        if (result != null && result.files.isNotEmpty) {
          PlatformFile file = result.files.first;
          setState(() {
            _selectedImage = File(file.path!);
          });
        }
      } else {
        // Mobile Handling (يبقى كما هو)
        final pickedFile = await ImagePicker().pickImage(
          source: source,
          imageQuality: 85,
          maxWidth: 800,
        );

        if (pickedFile != null) {
          setState(() {
            _selectedImage = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      print('حدث خطأ أثناء اختيار الصورة: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceDialog(BuildContext context, bool isMobile) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.orange.shade800),
              title: Text('اختر من المعرض'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android ||
                defaultTargetPlatform == TargetPlatform.iOS)
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.orange.shade800),
                title: Text('التقاط صورة جديدة'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('الصورة المختارة: $_selectedImage');
    return Scaffold(
      body: ResponsiveHelper.isMobile(context)
          ? _buildMobileLayout(context)
          : _buildDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          _buildAvatarSection(),
          SizedBox(height: 30),
          _buildProfileCard(context, isMobile: true),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.only(right: 40),
                  child: _buildAvatarSection(desktopMode: true),
                ),
              ),
              Expanded(
                flex: 2,
                child: _buildProfileCard(context, isMobile: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection({bool desktopMode = false}) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showImageSourceDialog(context, !desktopMode),
          child: Container(
            padding: EdgeInsets.all(desktopMode ? 12 : 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.orange.shade300,
                width: desktopMode ? 4 : 3,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: desktopMode ? 128 : 96,
                  height: desktopMode ? 128 : 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange.shade100,
                    image: _pickedFile != null
                        ? DecorationImage(
                            image: kIsWeb
                                ? NetworkImage(_pickedFile!.path)
                                : FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _pickedFile == null
                      ? Icon(
                          Icons.person_rounded,
                          size: desktopMode ? 80 : 60,
                          color: Colors.orange.shade800,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(desktopMode ? 8 : 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: desktopMode ? 24 : 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (desktopMode) ...[
          SizedBox(height: 20),
          Text('ضياء بني جابر',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800)),
          SizedBox(height: 8),
          Text('الحساب الشخصي',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
        ],
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context, {required bool isMobile}) {
    return Card(
      elevation: isMobile ? 4 : 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 30),
        child: Column(
          children: [
            _buildEditableField(
              context,
              label: 'الاسم الكامل',
              value: 'ضياء بني جابر',
              icon: Icons.person_outline_rounded,
              isMobile: isMobile,
            ),
            Divider(height: isMobile ? 30 : 40, color: Colors.grey.shade200),
            _buildEditableField(
              context,
              label: 'البريد الإلكتروني',
              value: 'diaa@example.com',
              icon: Icons.email_outlined,
              isMobile: isMobile,
            ),
            Divider(height: isMobile ? 30 : 40, color: Colors.grey.shade200),
            _buildEditableField(
              context,
              label: 'رقم الهاتف',
              value: '+970 59-0000000',
              icon: Icons.phone_android_outlined,
              isMobile: isMobile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(BuildContext context,
      {required String label,
      required String value,
      required IconData icon,
      required bool isMobile}) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange.shade800, size: isMobile ? 28 : 32),
        SizedBox(width: isMobile ? 15 : 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: isMobile ? 14 : 16,
                  )),
              SizedBox(height: isMobile ? 4 : 8),
              Text(value,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  )),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.edit_outlined,
              color: Colors.orange.shade600, size: isMobile ? 26 : 30),
          onPressed: () => _showEditDialog(context, label, value, isMobile),
        ),
      ],
    );
  }

  void _showEditDialog(
      BuildContext context, String field, String currentValue, bool isMobile) {
    final TextEditingController controller =
        TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.all(isMobile ? 20 : 30),
        titlePadding: EdgeInsets.all(isMobile ? 20 : 30),
        title: Text('تعديل $field',
            textAlign: TextAlign.right,
            style: TextStyle(
                color: Colors.orange.shade800, fontSize: isMobile ? 20 : 24)),
        content: SizedBox(
          width: isMobile ? null : MediaQuery.of(context).size.width * 0.4,
          child: TextFormField(
            controller: controller,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.orange.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.all(isMobile ? 15 : 20),
            ),
            style: TextStyle(fontSize: isMobile ? 16 : 18),
          ),
        ),
        actionsPadding: EdgeInsets.only(
            bottom: isMobile ? 15 : 20,
            left: isMobile ? 20 : 30,
            right: isMobile ? 20 : 30),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 15 : 25,
                      vertical: isMobile ? 10 : 15),
                  backgroundColor: Colors.red.shade100,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('حذف',
                    style: TextStyle(
                        color: Colors.red.shade800,
                        fontSize: isMobile ? 14 : 16)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 15 : 25,
                      vertical: isMobile ? 10 : 15),
                  backgroundColor: Colors.orange.shade800,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('حفظ التغييرات',
                    style: TextStyle(
                        color: Colors.white, fontSize: isMobile ? 14 : 16)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
