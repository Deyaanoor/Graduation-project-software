const express = require('express');
const connectDB = require('../config/db');
const router = express.Router();
const { getReports, addReport, getReportDetails, upload,updateReport ,deleteReport,getReportsToClient} = require('../controllers/reportController');

router.get('/:userId', getReports);

router.get('/reports/:id/:name', getReportsToClient);

router.get('/report/:id', getReportDetails);

router.post('/', upload.array('images', 5), addReport);

router.patch('/updateReport/:id', upload.array('images', 10), updateReport);

router.delete('/deleteReport/:id',deleteReport )

module.exports = router;
