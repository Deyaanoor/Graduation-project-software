import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/screens/Admin/Garage/components/GarageForm.dart';
import 'package:flutter_provider/screens/Admin/Garage/components/AddCart.dart';
import 'package:flutter_provider/screens/Admin/Garage/components/GarageCard.dart';
import 'package:flutter_provider/screens/Admin/Garage/AddGaragePage.dart';
import 'package:flutter_provider/widgets/CustomDialog.dart';
import 'package:flutter_provider/widgets/CustomPainter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_provider/providers/garage_provider.dart';

class GaragePage extends ConsumerWidget {
  const GaragePage({super.key});

  void _openAddForm(BuildContext context, WidgetRef ref) {
    if (ResponsiveHelper.isMobile(context)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddGaragePage()),
      );
    } else {
      final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
      final List<TextEditingController> _controllers = [
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
      ];

      Future<void> _submitForm() async {
        if (_formKey.currentState!.validate()) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          try {
            final addGarage = ref.read(addGarageProvider);
            await addGarage(
              name: _controllers[0].text,
              location: _controllers[1].text,
              ownerName: _controllers[2].text,
              ownerEmail: _controllers[3].text,
              cost: _controllers[4].text,
            );
            final refreshGarages = ref.read(refreshGaragesProvider);
            refreshGarages(ref);

            // ignore: use_build_context_synchronously
            Navigator.of(context).pop(); // pop loading dialog

            CustomDialogPage.show(
              // ignore: use_build_context_synchronously
              context: context,
              type: MessageType.success,
              title: 'Success',
              content: 'Garage added successfully',
            );
          } catch (e) {
            CustomDialogPage.show(
              context: context,
              type: MessageType.error,
              title: 'Error',
              content: 'An error occurred: $e',
            );
          }
        }
      }

      Widget _buildTextFormField({
        required BuildContext context,
        required TextEditingController controller,
        required IconData icon,
        TextInputType keyboardType = TextInputType.text,
        required String label,
        String? Function(String?)? validator,
      }) {
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            icon: Icon(icon),
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          keyboardType: keyboardType,
          validator: validator,
        );
      }

      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).dialogBackgroundColor,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Add New Garage',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GarageForm(
                        formKey: _formKey,
                        controllers: _controllers,
                        onSubmit: _submitForm,
                        buildTextFormField: _buildTextFormField,
                        buttonText: 'save',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garagesAsync = ref.watch(garagesProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[900]! : Colors.white;
    final waveColor = Colors.orange;

    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            painter: WaveBackground(
              color1: waveColor,
              color2: backgroundColor,
            ),
            size: Size.infinite,
          ),
          Container(
            color: Colors.transparent,
            child: garagesAsync.when(
              data: (garages) => _GarageGrid(
                garages: garages,
                onAddPressed: () => _openAddForm(context, ref),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _GarageGrid extends StatelessWidget {
  final List<Map<String, dynamic>> garages;
  final VoidCallback onAddPressed;

  const _GarageGrid({required this.garages, required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final crossAxisCount = isDesktop ? 3 : 1;
    final totalWidth = (300 * crossAxisCount) + (16 * (crossAxisCount - 1));

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            width: totalWidth.toDouble(),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 200,
              ),
              itemCount: garages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return AddCard(onTap: onAddPressed);
                }
                final garage = garages[index - 1];
                return GarageCard(
                  id: garage['_id'] ?? '',
                  name: garage['name'] ?? '',
                  location: garage['location'] ?? '',
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
