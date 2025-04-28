const express = require('express');
const router = express.Router();
const { getMonthlyReportsCount ,getEmployee,
    getEmployeeSalary,getMonthlySummary,
    getModelsSummary,getTopEmployeesThisMonth,
    getReports} = require('../controllers/overviewController');

router.post('/reports-count', getMonthlyReportsCount);
router.post('/employee-count', getEmployee);
router.post('/employee-salary', getEmployeeSalary); 
router.post('/MonthlySummary', getMonthlySummary);
router.post('/get-models-summary', getModelsSummary);
router.post('/top-employees', getTopEmployeesThisMonth);
router.post('/reports', getReports);

module.exports = router;
