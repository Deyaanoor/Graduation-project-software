const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const userRoutes = require("./routes/userRoutes");
const errorHandler = require("./middleware/errorHandler");

dotenv.config();

const app = express();
const port = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.send("✅ API is working!");
});

// ✅ استخدام المسارات الخاصة بالمستخدمين
app.use("/api/users", userRoutes);

// ✅ Middleware لمعالجة الأخطاء
app.use(errorHandler);

app.listen(port, () => console.log(`🚀 Server running on port ${port}`));
