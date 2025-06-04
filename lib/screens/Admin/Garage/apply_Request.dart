import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/requestRegister.dart';
import 'package:flutter_provider/screens/PaymentDialog.dart';
import 'package:flutter_provider/screens/map.dart';
import 'package:flutter_provider/widgets/custom_snackbar.dart';
import 'package:flutter_provider/widgets/payment_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_provider/widgets/custom_button.dart';
import 'package:flutter_provider/widgets/custom_text_field.dart';
import 'package:flutter_provider/screens/auth/logIn.dart';
import 'package:flutter_provider/screens/auth/Title_Project.dart';
import 'package:flutter_provider/widgets/bezierContainer.dart';
import 'package:flutter_provider/screens/auth/divider_widget.dart';
import 'package:latlong2/latlong.dart';

class ApplyRequestPage extends ConsumerStatefulWidget {
  const ApplyRequestPage({super.key});

  @override
  ConsumerState<ApplyRequestPage> createState() => _ApplyRequestPageState();
}

class _ApplyRequestPageState extends ConsumerState<ApplyRequestPage> {
  final TextEditingController garageNameController = TextEditingController();
  final TextEditingController garageLocationController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String selectedSubscription = 'trial';

  @override
  void dispose() {
    garageNameController.dispose();
    garageLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final userId = ref.read(userIdProvider).value;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (width < 900) {
            return _buildMobileView(
              context,
              garageNameController,
              garageLocationController,
              selectedSubscription,
              (value) {
                selectedSubscription = value!;
              },
              height,
              ref,
              _formKey,
              userId,
            );
          } else {
            return _buildDesktopView(
              context,
              garageNameController,
              garageLocationController,
              selectedSubscription,
              (value) {
                selectedSubscription = value!;
              },
              height,
              width,
              ref,
              _formKey,
              userId,
            );
          }
        },
      ),
    );
  }

  Widget _buildMobileView(
    BuildContext context,
    TextEditingController garageNameController,
    TextEditingController garageLocationController,
    String selectedSubscription,
    ValueChanged<String?> onSubscriptionChanged,
    double height,
    WidgetRef ref,
    GlobalKey<FormState> _formKey,
    String? userId,
  ) {
    return Scaffold(
      body: SizedBox(
        height: height,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -height * 0.15,
              right: -MediaQuery.of(context).size.width * 0.4,
              child: BezierContainer(),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: height * 0.2),
                      TitlePro(),
                      SizedBox(height: 50),
                      CustomTextField(
                        label: "Garage Name",
                        hint: "Enter your garage name",
                        icon: Icons.garage,
                        controller: garageNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter garage name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: garageLocationController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Garage Location",
                          hintText: "Select garage location",
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        onTap: () async {
                          final LatLng? result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FreeMapPickerPage(),
                            ),
                          );

                          if (result != null) {
                            garageLocationController.text =
                                '{"latitude":${result.latitude},"longitude":${result.longitude}}';
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      _buildSubscriptionDropdown(
                        selectedSubscription,
                        onSubscriptionChanged,
                      ),
                      SizedBox(height: 30),
                      CustomButton(
                        text: "Apply",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentScreen(),
                            ),
                          );
                        },
                        isGradient: true,
                      ),
                      SizedBox(height: 30),

                      CustomButton(
                        text: "Apply",
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            handleApply(
                              context,
                              ref,
                              garageNameController,
                              garageLocationController,
                              selectedSubscription,
                              userId,
                            );
                          }
                        },
                        isGradient: true,
                      ),
                      SizedBox(height: 20),
                      DividerWidget(),
                      _loginAccountLabel(context),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopView(
    BuildContext context,
    TextEditingController garageNameController,
    TextEditingController garageLocationController,
    String selectedSubscription,
    ValueChanged<String?> onSubscriptionChanged,
    double height,
    double width,
    WidgetRef ref,
    GlobalKey<FormState> _formKey,
    String? userId,
  ) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: height * 0.85,
          maxWidth: width * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: width * 0.3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade700, Colors.orange.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(25),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: height * 0.4,
                          maxWidth: width * 0.2,
                        ),
                        child: Image.network(
                          'https://i.postimg.cc/65vkqwg3/cleaned-image-3-removebg-preview.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                        ),
                      ),
                      SizedBox(height: 30),
                      TitlePro(),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TitlePro(),
                        SizedBox(height: 30),
                        CustomTextField(
                          label: "Garage Name",
                          hint: "Enter your garage name",
                          icon: Icons.garage,
                          controller: garageNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter garage name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: garageLocationController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Garage Location",
                            hintText: "Select garage location",
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          onTap: () async {
                            final LatLng? result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FreeMapPickerPage(),
                              ),
                            );

                            if (result != null) {
                              garageLocationController.text =
                                  '{"latitude":${result.latitude},"longitude":${result.longitude}}';
                            }
                          },
                        ),
                        SizedBox(height: 20),
                        _buildSubscriptionDropdown(
                          selectedSubscription,
                          onSubscriptionChanged,
                        ),
                        SizedBox(height: 30),
                        CustomButton(
                          text: "Apply",
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              handleApply(
                                context,
                                ref,
                                garageNameController,
                                garageLocationController,
                                selectedSubscription,
                                userId,
                              );
                            }
                          },
                          isGradient: true,
                        ),
                        SizedBox(height: 20),
                        DividerWidget(),
                        _loginAccountLabel(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionDropdown(
    String selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Subscription Type",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
          items: [
            DropdownMenuItem(value: 'trial', child: Text('Trial')),
            DropdownMenuItem(value: '6months', child: Text('6 Months')),
            DropdownMenuItem(value: '1year', child: Text('1 Year')),
          ],
          onChanged: onChanged,
          validator: (value) {
            if (value == null) {
              return 'Please select a subscription type';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _loginAccountLabel(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: const Text(
          "Already have an account? Login",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  void handleApply(
    BuildContext context,
    WidgetRef ref,
    TextEditingController garageNameController,
    TextEditingController garageLocationController,
    String subscriptionType,
    String? userId,
  ) {
    if (garageNameController.text.isEmpty ||
        garageLocationController.text.isEmpty) {
      CustomSnackBar.showErrorSnackBar(context, "Please fill in all fields.");
      return;
    }

    if (userId == null) {
      CustomSnackBar.showErrorSnackBar(context, "User not authenticated.");
      return;
    }

    // افتح نافذة الدفع هنا

    final garageData = {
      'garageName': garageNameController.text,
      'garageLocation': garageLocationController.text,
      'subscriptionType': subscriptionType,
      'user_id': userId,
    };
    try {
      ref.read(applyGarageProvider(garageData).future);
      CustomSnackBar.showSuccessSnackBar(
        context,
        "Application submitted successfully.",
      );
    } catch (e) {
      CustomSnackBar.showErrorSnackBar(
        context,
        "Application failed: ${e.toString()}",
      );
    }
  }
}
