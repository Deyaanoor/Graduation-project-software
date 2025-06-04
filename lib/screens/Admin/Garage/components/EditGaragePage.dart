import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/garage_provider.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_provider/screens/Admin/Garage/components/GarageForm.dart';
import 'package:flutter_provider/widgets/CustomDialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditGaragePage extends ConsumerStatefulWidget {
  final String garageId;
  const EditGaragePage({super.key, required this.garageId});

  @override
  ConsumerState<EditGaragePage> createState() => _EditGaragePageState();
}

class _EditGaragePageState extends ConsumerState<EditGaragePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _costController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGarageData();
  }

  Future<void> _loadGarageData() async {
    try {
      final garageData =
          await ref.read(garageByIdProvider(widget.garageId).future);

      _nameController.text = garageData['name'];
      _locationController.text = garageData['location'];
      _ownerNameController.text = garageData['ownerName'];
      _ownerEmailController.text = garageData['ownerEmail'];
      _costController.text = garageData['cost'];
    } catch (e) {
      debugPrint('فشل تحميل بيانات الجراج: $e');
    }
  }

  Future<void> _submitForm() async {
    final lang = ref.watch(languageProvider);
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => _isLoading = true);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        await ref.read(updateGarageProvider)(
          id: widget.garageId,
          name: _nameController.text,
          location: _locationController.text,
          ownerName: _ownerNameController.text,
          ownerEmail: _ownerEmailController.text,
          cost: _costController.text,
        );

        Navigator.pop(context); // Close the loading dialog
        setState(() => _isLoading = false);

        CustomDialogPage.show(
          context: context,
          type: MessageType.success,
          title: lang['success'] ?? 'نجاح',
          content: lang['garageEdited'] ?? 'تم تعديل الجراج بنجاح',
        );

        Navigator.pop(context); // العودة للصفحة السابقة
      } catch (e) {
        Navigator.pop(context); // تأكد من إغلاق اللودينج
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('${lang['editError'] ?? 'حدث خطأ أثناء التعديل'}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang['editGarage'] ?? 'تعديل الجراج'),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: GarageForm(
          formKey: _formKey,
          controllers: [
            _nameController,
            _locationController,
            _ownerNameController,
            _ownerEmailController,
            _costController,
          ],
          onSubmit: _submitForm,
          buildTextFormField: _buildTextFormField,
          buttonText: lang['edit'] ?? 'تعديل',
          isLoading: _isLoading,
          lang: lang,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color:
              Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7) ??
                  Colors.black.withOpacity(0.7),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange),
        ),
        prefixIcon: Icon(icon, color: Colors.orange),
      ),
      validator: validator,
    );
  }
}
