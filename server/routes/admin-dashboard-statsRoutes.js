const express = require("express");
const router = express.Router();
const { getDashboardStats } = require("../controllers/admin-dashboard-stats");

router.get("/dashboard-stats", getDashboardStats);

module.exports = router;
