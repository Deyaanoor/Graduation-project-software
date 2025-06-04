const express = require('express');
const {
  addEmployee,
  getAllEmployees,
  deleteEmployee,
  updateEmployee,
  getEmployeeGarageInfo,   // استيراد الفنكشن الجديد
} = require('../controllers/employeeController');

const router = express.Router();

router.get('/', getAllEmployees);

router.post('/add-employee', addEmployee);

router.delete('/employee/:email', deleteEmployee);

router.put('/employee/:email', updateEmployee);

router.get('/employee/:userId/garage-info', getEmployeeGarageInfo);

module.exports = router;
