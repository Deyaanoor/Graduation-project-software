const express = require('express');
const cors = require('cors');
const stripe = require('stripe')('sk_test_51RWJeyQTAIRgjFlHl2GYhF7lz44cM6NitFgEBuZEeBq20oXLD0f3eNJVfU8FlZidG8GLUeYGVPr8nQZvHkPGyD7F00HShjlvC8');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.post('/payments/create-payment-intent', async (req, res) => {
    try {
        const { amount, currency = 'usd' } = req.body;

        // Create a PaymentIntent with the order amount and currency
        const paymentIntent = await stripe.paymentIntents.create({
            amount: parseInt(amount),
            currency: currency,
            automatic_payment_methods: {
                enabled: true,
            },
        });

        res.json({
            clientSecret: paymentIntent.client_secret,
        });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ error: error.message });
    }
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
}); 