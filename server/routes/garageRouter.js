const express = require('express');
const router = express.Router();

const {
  addGarage,
  getGarages,
  getGarageById,
  deleteGarage,
  updateGarage
} = require('../controllers/garageController');
router.post('/add', addGarage);
router.get('/', getGarages);
router.get('/:id', getGarageById);
router.delete('/:id', deleteGarage);
router.put('/:id', updateGarage);

module.exports = router;
