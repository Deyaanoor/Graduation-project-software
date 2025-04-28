import 'package:flutter/material.dart';
import 'package:flutter_provider/screens/Admin/Garage/components/GarageForm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_provider/widgets/CustomDialog.dart';
import 'package:flutter_provider/providers/garage_provider.dart';

class AddGaragePage extends ConsumerStatefulWidget {
  const AddGaragePage({super.key});

  @override
  ConsumerState<AddGaragePage> createState() => _AddGaragePageState();
}

class _AddGaragePageState extends ConsumerState<AddGaragePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _costController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        _isLoading = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        final addGarage = ref.read(addGarageProvider);
        await addGarage(
          name: _nameController.text,
          location: _locationController.text,
          ownerName: _ownerNameController.text,
          ownerEmail: _ownerEmailController.text,
          cost: _costController.text,
        );
        _isLoading = false;

        ref.invalidate(garagesProvider);
        Navigator.pop(context);

        CustomDialogPage.show(
          context: context,
          type: MessageType.success,
          title: 'Success',
          content: 'تمت إضافة الجراج بنجاح',
        );

        Navigator.pop(context); // الرجوع للصفحة السابقة
      } catch (e) {
        Navigator.pop(context); // تأكد تغلق اللودينج في حالة الخطأ
        debugPrint('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة جراج جديد'),
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
          buttonText: 'حفظ',
          isLoading: _isLoading,
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
