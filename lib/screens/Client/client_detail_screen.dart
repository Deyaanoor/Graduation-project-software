import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/clientProvider.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_provider/widgets/custom_button.dart';
import 'package:flutter_provider/widgets/custom_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClientDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> client;

  const ClientDetailScreen({required this.client});

  @override
  ConsumerState<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends ConsumerState<ClientDetailScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    nameController = TextEditingController(text: widget.client['name']);
    emailController =
        TextEditingController(text: widget.client['email'].toString());
    phoneController =
        TextEditingController(text: widget.client['phoneNumber'].toString());
  }

  void _showDiscardChangesDialog(
    Map<String, dynamic> lang,
  ) {
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
                style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {}

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Client?'),
        content: const Text('Are you sure you want to delete this Client?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteClient();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  Future<void> _deleteClient() async {
    try {
      final userId = ref.watch(userIdProvider).value;
      await ref.read(deleteClientProvider)(widget.client['email'], userId!);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('client deleted successfully!')),
      );
      ref.watch(clientsProvider(userId));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Widget _buildFormContent(
    Map<String, dynamic> lang,
  ) {
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
                      // enabled: isEditing,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: emailController,
                      label: lang['email'] ?? 'Email',
                      icon: Icons.email,
                      // enabled: isEditing,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: phoneController,
                      label: lang['phoneNumber'] ?? 'Phone',
                      icon: Icons.phone,
                      inputType: TextInputType.phone,
                      // enabled: isEditing,
                    ),
                    const SizedBox(height: 16),
                    _buildActionButtons(lang),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    Map<String, dynamic> lang,
  ) {
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
                  onPressed: () => _showDiscardChangesDialog(lang),
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
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final screenSize = MediaQuery.of(context).size;
    final lang = ref.watch(languageProvider);

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
                    Text(lang['clientDetails'] ?? 'Client Details',
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
                child: _buildFormContent(lang),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            lang['clientDetails'] ?? 'Client Details',
          ),
          backgroundColor: Colors.orange,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: _buildFormContent(lang),
      );
    }
  }
}
