const express = require("express");
const router = express.Router();

const {
  addGarage,
  getGarages,
  getGarageById,
  deleteGarage,
  updateGarage,
  getGarageLocations,
  getGarageInfo,
} = require("../controllers/garageController");
router.post("/add", addGarage);
router.get("/locations", getGarageLocations);
router.get("/", getGarages);
router.get("/:id", getGarageById);
router.delete("/:id", deleteGarage);
router.put("/:id", updateGarage);
router.get("/garage/info/:userId", getGarageInfo);

module.exports = router;
