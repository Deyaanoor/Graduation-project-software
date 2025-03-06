const connectDB = require("../config/db");

// ✅ جلب جميع المستخدمين
const getUsers = async (req, res) => {
  try {
    const database = await connectDB();
    const usersCollection = database.collection("users");

    const users = await usersCollection.find().toArray();
    res.json(users);
  } catch (error) {
    console.error("❌ Error fetching users:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

// ✅ إضافة مستخدم جديد
const addUser = async (req, res) => {
  try {
    const database = await connectDB();
    const usersCollection = database.collection("users");

    const newUser = req.body;
    const result = await usersCollection.insertOne(newUser);

    res.status(201).json({ message: "User added!", id: result.insertedId });
  } catch (error) {
    console.error("❌ Error adding user:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

module.exports = { getUsers, addUser };
