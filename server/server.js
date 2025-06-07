const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const connectDB = require("./config/db");
const newsRoutes = require("./routes/newsRouter");
const reportsRoutes = require("./routes/reportRouter");
const userRoutes = require("./routes/userRouter");
const employeeRoutes = require("./routes/employeeRouter");
const garageRoutes = require("./routes/garageRouter");
// const notificationsRoutes = require("./routes/notificationsRoutes");
const overviewRoutes = require("./routes/overviewRoutes");
const contactUsRoutes = require("./routes/contactUsRoutes");
const clientRoutes = require("./routes/clientRouter");
const requestRoutes = require("./routes/requestRouter");
const request_register = require("./routes/applyRequestRoutes");
const admin_dashboard_stats = require("./routes/admin-dashboard-statsRoutes");
const paymentRoutes = require('./routes/paymentRoutes');
const plansRoutes = require('./routes/planRouter');

dotenv.config({ path: "../assets/.env" });
console.log("Server time:", new Date().toISOString());

// const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const app = express();
const port = process.env.PORT || 5000;

if (!process.env.MONGO_URI) {
  console.error("❌ MONGO_URI is not defined. Check your .env file.");
  process.exit(1);
}

connectDB();
app.use(express.urlencoded({ extended: true }));

app.use(cors());
app.use(express.json());
app.use("/news", newsRoutes);
app.use("/reports", reportsRoutes);
app.use("/users", userRoutes);
app.use("/employees", employeeRoutes);
app.use("/garages", garageRoutes);
// app.use("/notifications", notificationsRoutes);
app.use("/overview", overviewRoutes);
app.use("/contactMessages", contactUsRoutes);
app.use("/clients", clientRoutes);
app.use("/requests", requestRoutes);
app.use("/request_register", request_register);
app.use("/admin_dashboard_stats", admin_dashboard_stats);
app.use('/payments', paymentRoutes);
app.use('/plans', plansRoutes);


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
app.listen(port, () => console.log(`🚀 Server running on port ${port}`));
