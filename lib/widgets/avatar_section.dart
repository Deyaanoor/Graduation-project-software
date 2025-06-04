import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // تأكد من إضافة الحزمة
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class AvatarSection extends ConsumerStatefulWidget {
  final Map<String, dynamic> userData;
  final bool desktopMode;
  final String? userId;

  const AvatarSection({
    super.key,
    required this.userData,
    this.desktopMode = false,
    this.userId,
  });

  @override
  ConsumerState<AvatarSection> createState() => _AvatarSectionState();
}

class _AvatarSectionState extends ConsumerState<AvatarSection> {
  File? _selectedImage;
  Uint8List? _selectedImageWebBytes;
  bool isLoading = false;

  Future<void> _pickImage(
    ImageSource source,
    Map<String, String> lang,
  ) async {
    try {
      if (kIsWeb) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowCompression: true,
        );

        if (result != null) {
          setState(() {
            _selectedImageWebBytes = result.files.first.bytes;
            _selectedImage = null;
          });
        }
      } else if (source == ImageSource.camera) {
        final pickedFile = await ImagePicker().pickImage(
          source: source,
          imageQuality: 85,
          maxWidth: 800,
        );

        if (pickedFile != null) {
          setState(() {
            _selectedImage = File(pickedFile.path);
            _selectedImageWebBytes = null;
          });
        }
      } else {
        FilePickerResult? result = await FilePicker.platform.pickFiles();

        if (result != null) {
          setState(() {
            _selectedImage = File(result.files.first.path!);
            _selectedImageWebBytes = null;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang['pickImageFailed'] ?? 'فشل في اختيار الصورة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceDialog(BuildContext context, Map<String, String> lang) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.orange.shade800),
              title: Text(lang['chooseFromGallery'] ?? 'اختر من المعرض'),
              onTap: () {
                _pickImage(ImageSource.gallery, lang);
                Navigator.pop(context);
              },
            ),
            if (defaultTargetPlatform == TargetPlatform.android ||
                defaultTargetPlatform == TargetPlatform.iOS)
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.orange.shade800),
                title: Text(lang['takeNewPhoto'] ?? 'التقاط صورة جديدة'),
                onTap: () {
                  _pickImage(ImageSource.camera, lang);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateAvatar(
    Map<String, String> lang,
  ) async {
    if (_selectedImage == null && _selectedImageWebBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang['pleasePickImage'] ??
              'يرجى اختيار صورة لتحديث الصورة الرمزية'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await updateAvatar(
        userId: widget.userId!,
        imageFile: _selectedImageWebBytes ?? _selectedImage!,
        isWeb: kIsWeb,
      );

      setState(() {
        widget.userData['avatar'] = _selectedImageWebBytes != null
            ? 'data:image/jpeg;base64,' + base64Encode(_selectedImageWebBytes!)
            : _selectedImage!.path;
        isLoading = false;
      });

      ref.invalidate(getUserInfoProvider(widget.userId!));

      // عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang['avatarUpdated'] ?? 'تم تحديث الصورة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${lang['avatarUpdateFailed'] ?? 'فشل في تحديث الصورة'}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = widget.desktopMode;
    final lang = ref.watch(languageProvider);

    return Column(
      children: [
        GestureDetector(
          onTap: () => _showImageSourceDialog(context, lang),
          child: Container(
            padding: EdgeInsets.all(isDesktop ? 12 : 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.orange.shade300,
                width: isDesktop ? 4 : 3,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: isDesktop ? 128 : 96,
                  height: isDesktop ? 128 : 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange.shade100,
                    image: widget.userData['avatar'] != null
                        ? DecorationImage(
                            image: NetworkImage(widget.userData['avatar']),
                            fit: BoxFit.cover,
                          )
                        : _selectedImage != null ||
                                _selectedImageWebBytes != null
                            ? DecorationImage(
                                image: _selectedImageWebBytes != null
                                    ? MemoryImage(_selectedImageWebBytes!)
                                    : FileImage(_selectedImage!)
                                        as ImageProvider,
                                fit: BoxFit.cover,
                              )
                            : null,
                  ),
                  child: widget.userData['avatar'] == null &&
                          _selectedImage == null &&
                          _selectedImageWebBytes == null
                      ? Icon(
                          Icons.person_rounded,
                          size: isDesktop ? 80 : 60,
                          color: Colors.orange.shade800,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(isDesktop ? 8 : 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: isDesktop ? 24 : 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isDesktop) ...[
          SizedBox(height: 20),
          Text(
            widget.userData['name'] ?? lang['unknown'] ?? 'غير معروف',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            lang['profile'] ?? 'الحساب الشخصي',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
        isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () => _updateAvatar(lang),
                child: Text(lang['updateAvatar'] ?? 'تحديث الصورة'),
              ),
      ],
    );
  }
}
