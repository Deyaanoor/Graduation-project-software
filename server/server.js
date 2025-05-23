const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const connectDB = require("./config/db");
const newsRoutes = require("./routes/newsRouter"); 
const reportsRoutes = require("./routes/reportRouter"); 
const userRoutes = require("./routes/userRouter");
const employeeRoutes = require("./routes/employeeRouter");
const garageRoutes = require("./routes/garageRouter");
const notificationsRoutes = require("./routes/notificationsRoutes");
const overviewRoutes = require("./routes/overviewRoutes");
const contactUsRoutes = require("./routes/contactUsRoutes");
const clientRoutes = require("./routes/clientRouter");
const requestRoutes = require("./routes/requestRouter");
dotenv.config({ path: "../assets/.env" });


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
app.use('/reports', reportsRoutes);
app.use('/users', userRoutes);
app.use('/employees', employeeRoutes);
app.use('/garages', garageRoutes);
app.use('/notifications', notificationsRoutes);
app.use('/overview', overviewRoutes); 
app.use('/contactMessages', contactUsRoutes);
app.use('/clients', clientRoutes); 
app.use('/requests', requestRoutes);


app.listen(port, () => console.log(`🚀 Server running on port ${port}`));
