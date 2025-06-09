import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_provider/providers/plan_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentScreen extends ConsumerStatefulWidget {
  final String selectedSubscription;
  final String currency;
  const PaymentScreen({
    Key? key,
    required this.selectedSubscription,
    this.currency = 'USD',
  }) : super(key: key);

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  Map<String, dynamic>? paymentIntentData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeStripe();
  }

  Future<void> initializeStripe() async {
    try {
      await Stripe.instance.applySettings();
    } catch (e) {
      if (mounted) {
        final lang = ref.read(languageProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${lang['stripeInitError'] ?? 'خطأ في تهيئة Stripe'}: $e')),
        );
      }
    }
  }

  Future<void> makePayment(double planPrice) async {
    final lang = ref.read(languageProvider);
    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.post(
        Uri.parse(
            'https://graduation-project-software.onrender.com/payments/create-payment-intent'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'amount': planPrice.toInt().toString(),
          'currency': widget.currency,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            '${lang['paymentIntentFail'] ?? 'فشل في إنشاء PaymentIntent'}: ${response.body}');
      }

      final jsonResponse = jsonDecode(response.body);

      if (!jsonResponse.containsKey('clientSecret')) {
        throw Exception(
            lang['noClientSecret'] ?? 'لم يتم استلام clientSecret من السيرفر');
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: jsonResponse['clientSecret'],
          merchantDisplayName: 'MechPro',
          style: ThemeMode.light,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Colors.blue,
            ),
          ),
        ),
      );

      try {
        await Stripe.instance.presentPaymentSheet();
      } catch (e) {
        throw Exception(
            '${lang['showPaymentSheetFail'] ?? 'فشل في عرض شاشة الدفع'}: $e');
      }

      final paymentIntent = await Stripe.instance
          .retrievePaymentIntent(jsonResponse['clientSecret']);

      if (paymentIntent.status == PaymentIntentsStatus.Succeeded) {
        Navigator.pop(context, true); // فقط أرجع true ولا تظهر SnackBar هنا
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${lang['paymentError'] ?? '❌ خطأ في عملية الدفع'}: ${e.toString()}'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: lang['ok'] ?? 'حسناً',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
        Navigator.pop(context, false);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final planPriceAsync =
        ref.watch(getPlanByNameProvider(widget.selectedSubscription));
    final lang = ref.watch(languageProvider);

    return planPriceAsync.when(
      data: (planPrice) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
        final primaryColor = Colors.orange;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Text(lang['payment'] ?? 'الدفع'),
            centerTitle: true,
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  material.Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [Colors.orange.shade700, Colors.orange.shade400]
                              : [
                                  Colors.orange.shade300,
                                  Colors.orange.shade600
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.payment_rounded,
                            size: 50,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            '${widget.selectedSubscription} ${lang['plan'] ?? 'Plan'}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '$planPrice ${widget.currency}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                          onPressed: () => makePayment(planPrice),
                          icon: const Icon(Icons.lock),
                          label: Text(
                            lang['payNow'] ?? 'ادفع الآن',
                            style: const TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                        ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
            child: Text('${lang['errorOccurred'] ?? 'حدث خطأ'}: $error')),
      ),
    );
  }
}
