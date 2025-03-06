const express = require("express");
const { getUsers, addUser } = require("../controllers/userController");

const router = express.Router();

router.get("/", getUsers); // جلب جميع المستخدمين
router.post("/", addUser); // إضافة مستخدم جديد

module.exports = router;
