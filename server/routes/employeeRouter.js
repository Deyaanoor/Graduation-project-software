const express = require('express');
const { addEmployee, getAllEmployees, deleteEmployee, updateEmployee } = require('../controllers/employeeController');
const router = express.Router();

// تعديل المسار هنا لكي يتوافق مع الاستعلامات
router.get('/', getAllEmployees);  // get all employees with query params

router.post('/add-employee', addEmployee); // إضافة موظف باستخدام query params

router.delete('/employee/:email', deleteEmployee); // حذف موظف باستخدام البريد الإلكتروني

router.put('/employee/:email', updateEmployee); // تحديث موظف باستخدام البريد الإلكتروني

module.exports = router;
