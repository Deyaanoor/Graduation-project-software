const stripe = require('stripe')('sk_test_51RWJeyQTAIRgjFlHl2GYhF7lz44cM6NitFgEBuZEeBq20oXLD0f3eNJVfU8FlZidG8GLUeYGVPr8nQZvHkPGyD7F00HShjlvC8'); // حط secret key حقك هنا

exports.createPaymentIntent = async (req, res) => {
  try {
    const { amount } = req.body;

    if (!amount) {
      return res.status(400).json({ error: 'Amount is required' });
    }

    // إنشاء PaymentIntent مع المبلغ والعملة (مثلاً دولار)
    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency: 'usd',
    });

    res.json({ clientSecret: paymentIntent.client_secret });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
