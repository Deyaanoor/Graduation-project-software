const express = require('express');
const router = express.Router();
const { getReports, addReport, getReportDetails, upload } = require('../controllers/reportController');

router.get('/:userId', getReports);

router.get('/report/:id', getReportDetails);

router.post('/', upload.array('images', 5), addReport);

module.exports = router;
