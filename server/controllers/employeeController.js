const { ObjectId } = require('mongodb');
const connectDB = require('../config/db');

// إضافة موظف جديد
const addEmployee = async (req, res) => {
  const { name, email, phoneNumber, salary } = req.body;
  const { owner_id } = req.query;

  try {
    // تحقق من صحة الـ ObjectId
    if (!ObjectId.isValid(owner_id)) {
      return res.status(400).json({ message: 'Invalid owner_id format' });
    }

    const db = await connectDB();
    const garagesCollection = db.collection('garages');
    const employeesCollection = db.collection('employees');

    // نجيب الكراج الخاص بصاحب الحساب
    const garage = await garagesCollection.findOne({ owner_id: new ObjectId(owner_id) });

    if (!garage) {
      return res.status(404).json({ message: 'Garage not found for this owner' });
    }

    // تحقق إذا الموظف موجود مسبقًا في نفس الكراج
    const existingEmployee = await employeesCollection.findOne({
      email,
      phoneNumber,
      garage_id: garage._id,
    });

    if (existingEmployee) {
      return res.status(400).json({ message: 'Employee already exists in this garage' });
    }

    const newEmployee = {
      name,
      email,
      phoneNumber,
      salary,
      garage_id: garage._id,
    };

    await employeesCollection.insertOne(newEmployee);
    res.status(201).json({ message: 'Employee added successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error adding employee' });
  }
};

// الحصول على جميع الموظفين
const getAllEmployees = async (req, res) => {
  const { owner_id } = req.query;

  try {
    // تحقق من صحة الـ ObjectId
    if (!ObjectId.isValid(owner_id)) {
      return res.status(400).json({ message: 'Invalid owner_id format' });
    }

    const db = await connectDB();
    const garagesCollection = db.collection('garages');
    const employeesCollection = db.collection('employees');

    const garage = await garagesCollection.findOne({ owner_id: new ObjectId(owner_id) });

    if (!garage) {
      return res.status(404).json({ message: 'Garage not found for this owner' });
    }

    const employees = await employeesCollection
      .find({ garage_id: garage._id })
      .toArray();

    res.status(200).json(employees);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error fetching employees' });
  }
};

// حذف موظف
const deleteEmployee = async (req, res) => {
  const { email } = req.params;
  const { owner_id } = req.query;

  try {
    // تحقق من صحة الـ ObjectId
    if (!ObjectId.isValid(owner_id)) {
      return res.status(400).json({ message: 'Invalid owner_id format' });
    }

    const db = await connectDB();
    const garagesCollection = db.collection('garages');
    const employeesCollection = db.collection('employees');

    const garage = await garagesCollection.findOne({ owner_id: new ObjectId(owner_id) });

    if (!garage) {
      return res.status(404).json({ message: 'Garage not found for this owner' });
    }

    const result = await employeesCollection.deleteOne({
      email,
      garage_id: garage._id,
    });

    if (result.deletedCount === 0) {
      return res.status(404).json({ message: 'Employee not found in this garage' });
    }

    res.status(200).json({ message: 'Employee deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error deleting employee' });
  }
};

// تحديث موظف
const updateEmployee = async (req, res) => {
  const { email } = req.params;
  const { name, phoneNumber, salary } = req.body;
  const { owner_id } = req.query;

  try {
    // تحقق من صحة الـ ObjectId
    if (!ObjectId.isValid(owner_id)) {
      return res.status(400).json({ message: 'Invalid owner_id format' });
    }

    const db = await connectDB();
    const garagesCollection = db.collection('garages');
    const employeesCollection = db.collection('employees');

    const garage = await garagesCollection.findOne({ owner_id: new ObjectId(owner_id) });

    if (!garage) {
      return res.status(404).json({ message: 'Garage not found for this owner' });
    }

    const result = await employeesCollection.updateOne(
      { email, garage_id: garage._id },
      { $set: { name, phoneNumber, salary } }
    );

    if (result.matchedCount === 0) {
      return res.status(404).json({ message: 'Employee not found in this garage' });
    }

    res.status(200).json({ message: 'Employee updated successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error updating employee' });
  }
};

module.exports = {
  addEmployee,
  getAllEmployees,
  deleteEmployee,
  updateEmployee,
};
