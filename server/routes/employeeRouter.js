const express = require('express');
const { addEmployee, getAllEmployees, deleteEmployee, updateEmployee } = require('../controllers/employeeController');
const router = express.Router();


router.get('/', getAllEmployees);  

router.post('/add-employee', addEmployee); 

router.delete('/employee/:email', deleteEmployee); 

router.put('/employee/:email', updateEmployee); 

module.exports = router;
