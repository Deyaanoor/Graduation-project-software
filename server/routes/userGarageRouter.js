const express = require('express');
const router = express.Router();
const { getUserGarageData } = require('../controllers/userGarageController');

router.get('/user/:userId', getUserGarageData);

module.exports = router;