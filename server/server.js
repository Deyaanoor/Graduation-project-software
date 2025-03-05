const express = require("express");
const cors = require("cors");
const { MongoClient, ServerApiVersion } = require("mongodb");
require("dotenv").config(); // تحميل متغيرات البيئة

const app = express();
const port = process.env.PORT || 5000; // استخدم PORT من البيئة أو 5000

app.use(cors()); // تمكين CORS
app.use(express.json()); // تمكين JSON Parsing

// 🔹 تحميل متغيرات البيئة
const uri = process.env.MONGO_URI;

// 🔹 إعداد الاتصال بـ MongoDB
const client = new MongoClient(uri, {
  serverApi: {
    version: ServerApiVersion.v1,
    strict: true,
    deprecationErrors: true,
  },
});

// ✅ دالة الاتصال بقاعدة البيانات
async function connectDB() {
  try {
    await client.connect();
    console.log("✅ Connected to MongoDB Atlas!");
    return client.db("ProSoftware"); // اسم قاعدة البيانات
  } catch (error) {
    console.error("❌ MongoDB Connection Error:", error);
    process.exit(1); // إيقاف التطبيق في حالة الخطأ
  }
}

// ✅ Route لاختبار عمل الـ API
app.get("/", (req, res) => {
  res.send("✅ API is working!");
});

// ✅ Route لجلب جميع المستخدمين من قاعدة البيانات
app.get("/api/users", async (req, res) => {
  try {
    const database = await connectDB();
    const usersCollection = database.collection("users");

    const users = await usersCollection.find().toArray();
    res.json(users);
  } catch (error) {
    console.error("❌ Error fetching users:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

// ✅ Route لإضافة مستخدم جديد
app.post("/api/users", async (req, res) => {
  try {
    const database = await connectDB();
    const usersCollection = database.collection("users");

    const newUser = req.body; // البيانات القادمة من الطلب
    const result = await usersCollection.insertOne(newUser);

    res.status(201).json({ message: "User added!", id: result.insertedId });
  } catch (error) {
    console.error("❌ Error adding user:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

// ✅ تشغيل السيرفر
app.listen(port, () => console.log(`🚀 Server running on port ${port}`));

// إنشاء نموذج الموظف (Employee)
const employeeSchema = new mongoose.Schema({
  name: String,
  position: String,
  salary: Number
});

const Employee = mongoose.model('Employee', employeeSchema);

// مسار جلب جميع الموظفين
app.get('/employees', async (req, res) => {
  try {
    const employees = await Employee.find();
    res.json(employees);
  } catch (err) {
    res.status(500).send('Error retrieving employees');
  }
});

// مسار إضافة موظف جديد
app.post('/employees', async (req, res) => {
  const { name, position, salary } = req.body;
  console.log("Adding employee:", { name, position, salary });  // إضافة سجل للتحقق من البيانات المستلمة

  const newEmployee = new Employee({
    name,
    position,
    salary,
  });
  console.log("done");

  try {
    console.log("done");
    await newEmployee.save();
    res.status(201).send('Employee added');
    console.log("done");
  } catch (err) {
    console.error("Error adding employee:", err);  // إضافة سجل للتحقق من الأخطاء
    res.status(500).send('Error adding employee');
  }
});


// مسار حذف موظف
app.delete('/employees/:id', async (req, res) => {
  try {
    await Employee.findByIdAndDelete(req.params.id);
    res.status(200).send('Employee deleted');
  } catch (err) {
    res.status(500).send('Error deleting employee');
  }
});

// بدء السيرفر
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
