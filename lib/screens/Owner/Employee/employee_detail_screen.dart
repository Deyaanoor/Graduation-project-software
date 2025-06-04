import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/employeeProvider.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_provider/providers/overviewProvider.dart';
import 'package:flutter_provider/widgets/custom_button.dart';
import 'package:flutter_provider/widgets/custom_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmployeeDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> employee;

  const EmployeeDetailScreen({required this.employee});

  @override
  ConsumerState<EmployeeDetailScreen> createState() =>
      _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends ConsumerState<EmployeeDetailScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController salaryController;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    nameController = TextEditingController(text: widget.employee['name']);
    emailController =
        TextEditingController(text: widget.employee['email'].toString());
    phoneController =
        TextEditingController(text: widget.employee['phoneNumber'].toString());
    salaryController =
        TextEditingController(text: widget.employee['salary'].toString());
  }

  void _showDiscardChangesDialog() {
    final lang = ref.watch(languageProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang['discardChanges'] ?? 'Discard Changes?'),
        content: Text(lang['discardChangesMsg'] ??
            'Are you sure you want to discard changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang['cancel'] ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              _initializeControllers();
              setState(() => isEditing = false);
              Navigator.pop(context);
            },
            child: Text(lang['discard'] ?? 'Discard',
                style: const TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    final lang = ref.watch(languageProvider);
    try {
      final updatedData = {
        'name': nameController.text,
        'email': emailController.text,
        'phoneNumber': phoneController.text,
        'salary': double.parse(salaryController.text),
      };
      final userId = ref.watch(userIdProvider).value;
      await ref.read(updateEmployeeProvider)(
        widget.employee['email'],
        updatedData,
        userId!,
      );
      ref.invalidate(employeesProvider(userId));
      ref.invalidate(employeeSalaryProvider(userId));
      setState(() => isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(lang['changesSaved'] ?? 'Changes saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${lang['error'] ?? 'Error'}: ${e.toString()}')),
      );
    }
  }

  void _confirmDelete() {
    final lang = ref.watch(languageProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang['deleteEmployee'] ?? 'Delete Employee?'),
        content: Text(lang['deleteEmployeeMsg'] ??
            'Are you sure you want to delete this employee?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang['cancel'] ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteEmployee();
            },
            child: Text(lang['delete'] ?? 'Delete',
                style: const TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  Future<void> _deleteEmployee() async {
    final lang = ref.watch(languageProvider);
    try {
      final userId = ref.watch(userIdProvider).value;
      await ref.read(deleteEmployeeProvider)(widget.employee['email'], userId!);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                lang['employeeDeleted'] ?? 'Employee deleted successfully!')),
      );
      ref.watch(employeesProvider(userId));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${lang['error'] ?? 'Error'}: ${e.toString()}')),
      );
    }
  }

  Widget _buildFormContent() {
    final lang = ref.watch(languageProvider);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: nameController,
                      label: lang['name'] ?? 'Name',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: emailController,
                      label: lang['email'] ?? 'Email',
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: phoneController,
                      label: lang['phoneNumber'] ?? 'Phone',
                      icon: Icons.phone,
                      inputType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: salaryController,
                      label: lang['salary'] ?? 'Salary',
                      icon: Icons.attach_money,
                      inputType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final lang = ref.watch(languageProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 400;

        return Wrap(
          alignment: WrapAlignment.spaceEvenly,
          spacing: 16,
          runSpacing: 16,
          children: [
            if (!isEditing) ...[
              SizedBox(
                width: isWide ? null : double.infinity,
                child: CustomButton(
                  onPressed: () => setState(() => isEditing = true),
                  text: lang['edit'] ?? 'Edit',
                  backgroundColor: Colors.orange,
                ),
              ),
            ],
            if (isEditing) ...[
              SizedBox(
                width: isWide ? null : double.infinity,
                child: CustomButton(
                  onPressed: _saveChanges,
                  text: lang['saveChanges'] ?? 'Save Changes',
                  backgroundColor: Colors.orange,
                ),
              ),
              SizedBox(
                width: isWide ? null : double.infinity,
                child: CustomButton(
                  onPressed: _showDiscardChangesDialog,
                  text: lang['cancel'] ?? 'Cancel',
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final screenSize = MediaQuery.of(context).size;

    if (isDesktop) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.1,
          vertical: screenSize.height * 0.05,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 600,
            maxHeight: screenSize.height * 0.9,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(lang['employeeDetails'] ?? 'Employee Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            )),
                    IconButton(
                      icon: const Icon(Icons.close, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),
              Expanded(
                child: _buildFormContent(),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(lang['employeeDetails'] ?? 'Employee Details'),
          backgroundColor: Colors.orange,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: _buildFormContent(),
      );
    }
  }
}
