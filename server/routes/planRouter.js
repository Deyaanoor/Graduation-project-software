const express = require('express');
const router = express.Router();
const {
  createPlans,
  updatePlan,
  getPlanByName,
  getAllPlans
} = require('../controllers/planController');

router.get('/', getAllPlans);
router.post('/plans/init', createPlans);
router.put('/plans/:name', updatePlan);
router.get('/plans/:name', getPlanByName);

module.exports = router;
