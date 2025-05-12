const express = require('express');
const router = express.Router();
const {
  addContactMessage,
  getContactMessages,
  getContactMessagesByUserId,
  deleteContactMessage,
  updateContactMessageStatus,
} = require('../controllers/contactUsController');

// إضافة مشكلة تواصل جديدة
router.post('/add', addContactMessage);

// جلب جميع الرسائل
router.get('/', getContactMessages);

// جلب الرسائل الخاصة بمستخدم معين
router.get('/user/:userId', getContactMessagesByUserId);

// تحديث حالة الرسالة
router.patch('/update/:id', updateContactMessageStatus);

// حذف رسالة
router.delete('/delete/:id', deleteContactMessage);

module.exports = router;
