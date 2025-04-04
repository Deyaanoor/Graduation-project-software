const { MongoClient, ServerApiVersion } = require("mongodb");
const dotenv = require("dotenv");

dotenv.config();

const connectDB = async () => {
  try {
    const client = new MongoClient(process.env.MONGO_URI, {
      serverApi: {
        version: ServerApiVersion.v1,
        strict: true,
        deprecationErrors: true,
      },
    });

    await client.connect();

    const dbName = process.env.DB_NAME || "ProSoftware"; 
    const db = client.db(dbName);

    console.log(`✅ Connected to MongoDB Atlas! Database: ${db.databaseName}`);
    return db;
  } catch (error) {
    console.error("❌ MongoDB Connection Error:", error);
    process.exit(1); 
  }
};

module.exports = connectDB;
