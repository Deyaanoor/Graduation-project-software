import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentScreen extends StatefulWidget {
  final String amount;
  final String currency;
  const PaymentScreen({
    Key? key,
    required this.amount,
    this.currency = 'USD',
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
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
      print('خطأ في تهيئة Stripe: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تهيئة Stripe: $e')),
        );
      }
    }
  }

  Future<void> makePayment() async {
    try {
      setState(() {
        isLoading = true;
      });

      print('بدء عملية الدفع...');

      // 1. إنشاء PaymentIntent على السيرفر
      final response = await http.post(
        Uri.parse('https://graduation-project-software.onrender.com/payments/create-payment-intent'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'amount': widget.amount,
          'currency': widget.currency,
        }),
      );

      print('استجابة السيرفر: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('فشل في إنشاء PaymentIntent: ${response.body}');
      }

      final jsonResponse = jsonDecode(response.body);
      print('PaymentIntent Response: $jsonResponse');

      if (!jsonResponse.containsKey('clientSecret')) {
        throw Exception('لم يتم استلام clientSecret من السيرفر');
      }

      // 2. تهيئة شاشة الدفع
      print('جاري تهيئة شاشة الدفع...');
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

      // 3. عرض شاشة الدفع
      print('جاري عرض شاشة الدفع...');
      try {
        await Stripe.instance.presentPaymentSheet();
      } catch (e) {
        print('خطأ في عرض شاشة الدفع: $e');
        throw Exception('فشل في عرض شاشة الدفع: $e');
      }

      // 4. التحقق من حالة الدفع
      print('جاري التحقق من حالة الدفع...');
      final paymentIntent = await Stripe.instance.retrievePaymentIntent(jsonResponse['clientSecret']);
      print('حالة الدفع: ${paymentIntent.status}');
      
      if (paymentIntent.status == PaymentIntentsStatus.Succeeded) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ تم الدفع بنجاح!')),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('فشل في إتمام عملية الدفع: ${paymentIntent.status}');
      }
    } catch (e) {
      print('خطأ في عملية الدفع: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطأ في عملية الدفع: ${e.toString()}'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'حسناً',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدفع'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'المبلغ: ${widget.amount} ${widget.currency}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: makePayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text(
                  'ادفع الآن',
                  style: TextStyle(fontSize: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
