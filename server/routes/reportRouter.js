const express = require('express');
const router = express.Router();
const { getReports, addReport, getReportDetails, upload } = require('../controllers/reportController');

router.get('/', getReports);
router.get('/:id', getReportDetails);
router.post('/', upload.array('images', 5), addReport); // تغيير لاستقبال عدة صور

module.exports = router;