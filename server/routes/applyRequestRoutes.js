const express = require("express");
const {
  applyGarage,
  getAllRequests,
  updateRequestStatus,
} = require("../controllers/applyRequestController");
const router = express.Router();

router.post("/add_request", applyGarage);
router.get("/", getAllRequests);
router.put("/:requestId/status", updateRequestStatus);
module.exports = router;
