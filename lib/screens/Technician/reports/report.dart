import 'dart:convert';
import 'dart:io';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/home_provider.dart';
import 'package:flutter_provider/providers/notifications_provider.dart';
import 'package:flutter_provider/providers/overviewProvider.dart';
import 'package:flutter_provider/screens/Technician/reports/components/image_upload_section.dart';
import 'package:flutter_provider/screens/Technician/reports/components/repair_section.dart';
import 'package:flutter_provider/widgets/AIDesktopButton%20.dart';
import 'package:flutter_provider/widgets/CustomDialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_provider/widgets/custom_text_field.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_provider/providers/reports_provider.dart';
import 'dart:developer';
import 'dart:convert';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _ownerController = TextEditingController();
  final _plateController = TextEditingController();
  final _problemTitleController = TextEditingController();
  final _costController = TextEditingController();
  final _repairDescController = TextEditingController();
  final _partController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _symptomsController = TextEditingController();

  final stt.SpeechToText _speech = stt.SpeechToText();
  List<XFile> _images = [];
  bool _isListening = false;
  List<String> _selectedParts = [];
  @override
  void initState() {
    super.initState();

    final selectedReport = ref.read(selectedReportProvider);
    final editReport = ref.read(isEditModeProvider.notifier).state;

    log("EditReport $editReport");
    if (selectedReport != null) {
      _ownerController.text = selectedReport['owner'] ?? '';
      _plateController.text = selectedReport['plateNumber'] ?? '';
      _partController.text = selectedReport['part'] ?? '';
      _makeController.text = selectedReport['make'] ?? '';
      _modelController.text = selectedReport['model'] ?? '';
      _yearController.text = selectedReport['year']?.toString() ?? '';
      if (editReport != false) {
        _problemTitleController.text = selectedReport['issue'] ?? '';
        _costController.text = selectedReport['cost']?.toString() ?? '';
        _repairDescController.text = selectedReport['repairDescription'] ?? '';
        _symptomsController.text = selectedReport['symptoms'] ?? '';
        final imageUrls = selectedReport['imageUrls'];
        if (imageUrls != null) {
          initImagesFromUrls(List<String>.from(imageUrls as List));
        }
        final rawUsedParts = selectedReport['usedParts'];

        if (rawUsedParts != null) {
          if (rawUsedParts is String) {
            // إذا كانت مخزنة كنص JSON
            final decoded = jsonDecode(rawUsedParts);
            _selectedParts.addAll(List<String>.from(decoded));
          } else if (rawUsedParts is List) {
            // إذا كانت بالفعل List
            _selectedParts.addAll(List<String>.from(rawUsedParts));
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _plateController.dispose();
    _problemTitleController.dispose();
    _costController.dispose();
    _repairDescController.dispose();
    _partController.dispose();

    if (ref.read(isEditModeProvider)) {
      ref.read(isEditModeProvider.notifier).state = false;
    }
    super.dispose();
  }

  Future<void> initImagesFromUrls(List<String> urls) async {
    for (String url in urls) {
      try {
        XFile xfile = await urlToXFile(url);
        _images.add(xfile);
      } catch (e) {
        print("❌ Error downloading image: $e");
      }
    }
    setState(() {});
  }

  Future<XFile> urlToXFile(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      if (kIsWeb) {
        return XFile.fromData(response.bodyBytes, name: "web_image.jpg");
      } else {
        final dir = await getTemporaryDirectory();
        final filePath =
            '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final file = io.File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return XFile(file.path);
      }
    } else {
      throw Exception("❌ Failed to download image: ${response.statusCode}");
    }
  }

  void _addPart() {
    if (_partController.text.isNotEmpty) {
      setState(() => _selectedParts.add(_partController.text));
      _partController.clear();
    }
  }

  void _removePart(int index) {
    setState(() => _selectedParts.removeAt(index));
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? selectedImages = await picker.pickMultiImage();
    if (selectedImages != null) {
      setState(() => _images.addAll(selectedImages));
    }
  }

  void _toggleListening() async {
    final lang = ref.read(languageProvider);
    final currentLang = ref.read(languageProvider.notifier).currentLanguageCode;

    if (_isListening) {
      setState(() => _isListening = false);
      _speech.stop();
    } else {
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(lang['mic_permission_title'] ?? 'Permission Required'),
            content: Text(
                lang['mic_permission_content'] ?? 'Allow microphone access'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(lang['ok'] ?? 'OK'),
              ),
            ],
          ),
        );
        return;
      }

      final available = await _speech.initialize();
      print('Speech available: $available');
      if (available) {
        setState(() => _isListening = true);
        final locales = await _speech.locales();
        print('Supported locales: $locales');
        _speech.listen(
          onResult: (result) {
            setState(() {
              print('recognizedWords: ${result.recognizedWords}');
              _repairDescController.text = result.recognizedWords;
              _repairDescController.selection = TextSelection.fromPosition(
                TextPosition(offset: _repairDescController.text.length),
              );
            });
          },
          localeId: currentLang,
        );
      }
    }
  }

  bool isLoading = false;

  Future<void> _sendDataToAPI() async {
    setState(() {
      isLoading = true;
      _repairDescController.text = '';
    });

    final url = 'https://9641-35-236-177-189.ngrok-free.app/predict';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'Make': _makeController.text,
          'Model': _modelController.text,
          'Problem': _partController.text,
          'Symptoms': _plateController.text,
          'Year': int.parse(
              _yearController.text.isEmpty ? '0' : _yearController.text),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final solution = responseData['Solution'];

        setState(() {
          _repairDescController.text = '$solution';
        });
      } else {
        setState(() {
          _repairDescController.text = 'حدث خطأ أثناء الاتصال بالسيرفر.';
        });
      }
    } catch (e) {
      setState(() {
        _repairDescController.text = 'فشل الاتصال: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildLoadingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: Colors.orange),
        SizedBox(width: 10),
        Text(
          'جاري التحليل...',
          style: TextStyle(fontSize: 16, color: Colors.orange),
        ),
      ],
    );
  }

  Widget _buildMainContent(
      BuildContext context, Map<String, String> lang, String userName) {
    return ResponsiveHelper.isDesktop(context)
        ? _buildDesktopLayout(lang, userName)
        : _buildMobileLayout(lang, userName);
  }

  Widget _buildMobileLayout(Map<String, String> lang, String userName) {
    return Column(
      children: [
        _buildOwnerField(lang),
        const SizedBox(height: 20),
        _buildPlateAndCostRow(lang),
        const SizedBox(height: 20),
        _build_Make_Model_Year_Field(lang),
        const SizedBox(height: 20),
        _buildProblemTitleField(lang),
        const SizedBox(height: 20),
        _buildCarSymptomsField(lang),
        const SizedBox(height: 20),
        AIDesktopButton(
          onPressed: _sendDataToAPI,
        ),
        const SizedBox(height: 20),
        if (isLoading) buildLoadingIndicator(),
        const SizedBox(height: 20),
        _buildPartsSection(lang),
        const SizedBox(height: 20),
        _buildRepairSection(lang),
        const SizedBox(height: 20),
        _buildImageUploadSection(lang),
        const SizedBox(height: 30),
        _buildActionButtons(lang, userName),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildDesktopLayout(Map<String, String> lang, String userName) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildOwnerField(lang),
                  const SizedBox(height: 25),
                  _buildPlateAndCostRow(lang),
                  const SizedBox(height: 25),
                  _build_Make_Model_Year_Field(lang),
                  const SizedBox(height: 25),
                  _buildProblemTitleField(lang),
                  const SizedBox(height: 25),
                  _buildCarSymptomsField(lang),
                  const SizedBox(height: 25),
                  AIDesktopButton(
                    onPressed: _sendDataToAPI,
                  ),
                  const SizedBox(height: 20),
                  if (isLoading) buildLoadingIndicator(),
                ],
              ),
            ),
            const SizedBox(width: 40),
            Expanded(
              child: Column(
                children: [
                  _buildPartsSection(lang),
                  const SizedBox(height: 25),
                  _buildRepairSection(lang),
                  const SizedBox(height: 25),
                  _buildImageUploadSection(lang),
                  const SizedBox(height: 35),
                  _buildActionButtons(lang, userName),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerField(Map<String, String> lang) {
    return CustomTextField(
      label: lang['owner_name'] ?? 'Owner Name',
      hint: lang['enter_owner'] ?? 'Enter owner name',
      icon: Icons.person,
      controller: _ownerController,
      borderColor: Colors.orange,
      backgroundColor: Colors.white,
      iconColor: Colors.orange,
    );
  }

  Widget _buildPlateAndCostRow(Map<String, String> lang) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            label: lang['plate_number'] ?? 'Plate Number',
            hint: lang['enter_plate'] ?? 'Enter plate number',
            icon: Icons.directions_car,
            controller: _plateController,
            borderColor: Colors.orange,
            backgroundColor: Colors.white,
            iconColor: Colors.orange,
          ),
        ),
        SizedBox(width: ResponsiveHelper.isDesktop(context) ? 25 : 15),
        Expanded(
          child: CustomTextField(
            label: lang['cost'] ?? 'Cost',
            hint: lang['enter_cost'] ?? 'Enter cost',
            icon: Icons.attach_money,
            controller: _costController,
            inputType: TextInputType.number,
            borderColor: Colors.orange,
            backgroundColor: Colors.white,
            iconColor: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _build_Make_Model_Year_Field(Map<String, String> lang) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            label: lang['car_make'] ?? 'Car Make',
            hint: lang['enter_car_make'] ?? 'Enter Car Make',
            icon: Icons.car_crash,
            controller: _makeController,
            borderColor: Colors.orange,
            backgroundColor: Colors.white,
            iconColor: Colors.orange,
          ),
        ),
        SizedBox(width: ResponsiveHelper.isDesktop(context) ? 25 : 15),
        Expanded(
          child: CustomTextField(
            label: lang['car_model'] ?? 'Car Model',
            hint: lang['enter_car_model'] ?? 'Enter Car Model',
            icon: Icons.car_crash_outlined,
            controller: _modelController,
            borderColor: Colors.orange,
            backgroundColor: Colors.white,
            iconColor: Colors.orange,
          ),
        ),
        SizedBox(width: ResponsiveHelper.isDesktop(context) ? 25 : 15),
        Expanded(
          child: CustomTextField(
            label: lang['car_year'] ?? 'Car Year',
            hint: lang['enter_car_year'] ?? 'Enter Car Year',
            icon: Icons.date_range,
            controller: _yearController,
            borderColor: Colors.orange,
            backgroundColor: Colors.white,
            iconColor: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildCarSymptomsField(Map<String, String> lang) {
    return CustomTextField(
      label: lang['car_symptoms'] ?? 'Car Symptoms',
      hint: lang['enter_car_symptoms'] ?? 'Enter Car Symptoms',
      icon: Icons.car_repair_rounded,
      controller: _symptomsController,
      borderColor: Colors.orange,
      backgroundColor: Colors.white,
      iconColor: Colors.orange,
    );
  }

  Widget _buildProblemTitleField(Map<String, String> lang) {
    return CustomTextField(
      label: lang['problem_title'] ?? 'Problem Title',
      hint: lang['enter_problem_title'] ?? 'Enter problem title',
      icon: Icons.error_outline,
      controller: _problemTitleController,
      borderColor: Colors.orange,
      backgroundColor: Colors.white,
      iconColor: Colors.orange,
    );
  }

  Widget _buildPartsSection(Map<String, String> lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang['used_parts'] ?? 'Used Parts',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.deepOrange,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _partController,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                        decoration: InputDecoration(
                          hintText: lang['search_parts'] ?? 'Search parts',
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: _addPart,
                      ),
                    ),
                  ],
                ),
                if (_selectedParts.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(
                        _selectedParts.length,
                        (index) => Chip(
                          label: Text(_selectedParts[index]),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => _removePart(index),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRepairSection(Map<String, String> lang) {
    return RepairSection(
      controller: _repairDescController,
      isListening: _isListening,
      onVoicePressed: _toggleListening,
      hint: lang['steps_hint'] ?? 'Enter repair steps',
      voiceLabel: _isListening
          ? lang['stop_record'] ?? 'Stop Recording'
          : lang['voice_record'] ?? 'Voice Record',
      title: lang['repair_description'] ?? 'Repair Description',
      // isDesktop: ResponsiveHelper.isDesktop(context),
    );
  }

  Widget _buildImageUploadSection(Map<String, String> lang) {
    return ImageUploadSection(
      images: _images,
      onUpload: _pickImages,
      onDelete: _removeImage,
      title: lang['attach_photos'] ?? 'Attach Photos',
      // isDesktop: ResponsiveHelper.isDesktop(context),
    );
  }

  Widget _buildActionButtons(Map<String, String> lang, String userName) {
    final buttonPadding = ResponsiveHelper.isDesktop(context)
        ? const EdgeInsets.symmetric(vertical: 18, horizontal: 30)
        : const EdgeInsets.symmetric(vertical: 15);

    return Row(
      children: [
        SizedBox(width: ResponsiveHelper.isDesktop(context) ? 25 : 15),
        Expanded(
          child: ElevatedButton(
            onPressed: () => ref.watch(isEditModeProvider)
                ? _updateReport()
                : _submitReport(userName),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              ref.watch(isEditModeProvider)
                  ? 'Update'
                  : lang['send_admin'] ?? 'Send to Admin',
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveHelper.isDesktop(context) ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _submitReport(String userName) async {
    final lang = ref.read(languageProvider);
    final reportsNotifier = ref.read(reportsProvider.notifier);

    if (_formKey.currentState!.validate()) {
      try {
        // ✅ جهّز متغيرات الصور فقط إذا فيه صور
        List<Uint8List>? imageBytesList;
        List<String>? fileNames;

        if (_images.isNotEmpty) {
          imageBytesList = await Future.wait(
            _images.map((image) async => await image.readAsBytes()),
          );
          fileNames = _images.map((image) => image.name).toList();
        }

        final userId = ref.watch(userIdProvider).value;

        final reportId = await reportsNotifier.addReport(
          owner: _ownerController.text,
          cost: _costController.text,
          plateNumber: _plateController.text,
          issue: _problemTitleController.text,
          make: _makeController.text,
          model: _modelController.text,
          year: _yearController.text,
          symptoms: _symptomsController.text,
          repairDescription: _repairDescController.text,
          usedParts: _selectedParts,
          imageBytesList: imageBytesList, // ممكن تكون null
          fileNames: fileNames, // ممكن تكون null
          status: 'Pending',
          mechanicName: userName,
          userId: userId!,
        );
        ref.read(reportsProvider.notifier).fetchReports(userId: userId);

        await ref.read(notificationsProvider.notifier).sendNotification(
              adminId: userId,
              reportId: reportId,
              senderName: userName,
            );

        if (mounted) {
          CustomDialogPage.show(
            context: context,
            type: MessageType.success,
            title: 'Success',
            content: 'Report sent successfully',
          );
          _resetForm();
        }
        ref.invalidate(modelsSummaryProvider(userId));
        ref.invalidate(reportsProviderOverview(userId));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  Future<void> _updateReport() async {
    final userId = ref.watch(userIdProvider).value;

    final lang = ref.read(languageProvider);
    final reportsNotifier = ref.read(reportsProvider.notifier);
    final selectedReport = ref.read(selectedReportProvider);

    if (selectedReport == null) return;

    try {
      final updatedFields = <String, dynamic>{};

      if (_ownerController.text != selectedReport['owner']) {
        updatedFields['owner'] = _ownerController.text;
      }
      if (_plateController.text != selectedReport['plateNumber']) {
        updatedFields['plateNumber'] = _plateController.text;
      }
      if (_problemTitleController.text != selectedReport['issue']) {
        updatedFields['issue'] = _problemTitleController.text;
      }
      if (_costController.text != selectedReport['cost']?.toString()) {
        updatedFields['cost'] = _costController.text;
      }
      if (_repairDescController.text != selectedReport['repairDescription']) {
        updatedFields['repairDescription'] = _repairDescController.text;
      }
      if (_makeController.text != selectedReport['make']) {
        updatedFields['make'] = _makeController.text;
      }
      if (_modelController.text != selectedReport['model']) {
        updatedFields['model'] = _modelController.text;
      }
      if (_yearController.text != selectedReport['year']?.toString()) {
        updatedFields['year'] = _yearController.text;
      }
      if (_symptomsController.text != selectedReport['symptoms']) {
        updatedFields['symptoms'] = _symptomsController.text;
      }

      final originalParts =
          List<String>.from(selectedReport['usedParts'] ?? []);
      if (!const ListEquality().equals(_selectedParts, originalParts)) {
        updatedFields['usedParts'] = _selectedParts;
      }

      List<Uint8List>? imageBytesList;
      List<String>? fileNames;

      if (_images.isNotEmpty) {
        imageBytesList = await Future.wait(
          _images.map((image) async => await image.readAsBytes()),
        );
        fileNames = _images.map((image) => image.name).toList();
      }

      if (updatedFields.isNotEmpty || imageBytesList != null) {
        await reportsNotifier.updateReport(
          reportId: selectedReport['_id'],
          owner: updatedFields['owner'],
          cost: updatedFields['cost'],
          plateNumber: updatedFields['plateNumber'],
          issue: updatedFields['issue'],
          make: updatedFields['make'],
          model: updatedFields['model'],
          year: updatedFields['year'],
          symptoms: updatedFields['symptoms'],
          repairDescription: updatedFields['repairDescription'],
          usedParts: updatedFields['usedParts'],
          imageBytesList: imageBytesList,
          fileNames: fileNames,
        );

        if (mounted) {
          CustomDialogPage.show(
            context: context,
            type: MessageType.success,
            title: lang['success'] ?? 'Success',
            content: lang['report_updated'] ?? 'Report updated successfully',
          );
          _resetForm();
          ref.read(isEditModeProvider.notifier).state =
              false; // تفعيل وضع التعديل
        }
        if (userId != null) {
          ref.read(reportsProvider.notifier).fetchReports(userId: userId);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(lang['no_changes'] ?? 'No changes detected')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _selectedParts.clear();
      _images.clear();
      _ownerController.clear();
      _plateController.clear();
      _problemTitleController.clear();
      _costController.clear();
      _repairDescController.clear();
      _partController.clear();
      _makeController.clear();
      _modelController.clear();
      _yearController.clear();
      _symptomsController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final textDirection = ref.read(languageProvider.notifier).textDirection;

    final userId = ref.watch(userIdProvider).value;
    final userInfo =
        userId != null ? ref.watch(getUserInfoProvider(userId)).value : null;
    final userName =
        userInfo != null ? userInfo['name'] ?? 'بدون اسم' : 'جاري التحميل...';

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(
            ResponsiveHelper.isDesktop(context) ? 30 : 20,
          ),
          child: Form(
            key: _formKey,
            child: _buildMainContent(context, lang, userName),
          ),
        ),
      ),
    );
  }
}
