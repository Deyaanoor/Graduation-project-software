const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');  // استيراد حزمة CORS

const app = express();
const port = 5000;

app.use(cors());  // إضافة middleware الخاص بـ CORS

// إعدادات الـ Express لقراءة بيانات JSON
app.use(express.json());

// ربط السيرفر بـ MongoDB
mongoose.connect('mongodb://localhost:27017/employees', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => {
  console.log('Connected to MongoDB');
})
.catch((error) => {
  console.error('Error connecting to MongoDB: ', error);
});

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
