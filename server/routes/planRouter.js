const express = require('express');
const router = express.Router();
const {
  updatePlan,
  getPlanByName,
  getAllPlans,
  deletePlanById,
  addSinglePlan
} = require('../controllers/planController');

router.get('/', getAllPlans);
router.put('/plans/:name', updatePlan);
router.get('/plans/:name', getPlanByName);
router.post('/add', addSinglePlan);
router.delete('/:id', deletePlanById);


module.exports = router;
