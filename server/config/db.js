const { MongoClient } = require("mongodb");
const dotenv = require("dotenv");

dotenv.config(); // تحميل المتغيرات من ملف .env

const connectDB = async () => {
  try {
    const client = new MongoClient(process.env.MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true });
    await client.connect();
    
    const dbName = process.env.DB_NAME || "prosoftware"; // اسم القاعدة من .env أو افتراضيًا
    const db = client.db(dbName);

    console.log(`✅ Connected to the database: ${db.databaseName}`);
    return db;
  } catch (error) {
    console.error("❌ Error connecting to database:", error);
    throw new Error("Failed to connect to the database");
  }
};

module.exports = connectDB;
