const { MongoClient } = require("mongodb");
const dotenv = require("dotenv");
console.log("deyaa")
dotenv.config(); // تحميل المتغيرات من ملف .env
console.log("omar")
const connectDB = async () => {
  try {
    const client = new MongoClient(process.env.MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true });
    await client.connect();
    console.log("✅ Connected to the database");
    return client.db(); // إرجاع قاعدة البيانات
  } catch (error) {
    console.error("❌ Error connecting to database:", error);
    throw new Error("Failed to connect to the database");
  }
};

module.exports = connectDB;
