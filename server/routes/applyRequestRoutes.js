const express = require("express");
const {
  applyGarage,
  getAllRequests,
  updateRequestStatus,
  existRequest,
} = require("../controllers/applyRequestController");
const router = express.Router();

router.post("/add_request", applyGarage);
router.get("/", getAllRequests);
router.get("/status/:email", existRequest);
router.put("/:requestId/status", updateRequestStatus);
module.exports = router;
