const express = require("express");
const router = express.Router();

const { activateGarageSubscription } = require("../controllers/garageSubscriptionController");

router.patch("/activate/:userId", activateGarageSubscription);

module.exports = router;
