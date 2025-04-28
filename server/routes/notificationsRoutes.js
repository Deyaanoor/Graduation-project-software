const express = require('express');
const router = express.Router();
const { 
  createNotification,
  getNotifications,
  markAsRead,
  deleteNotification,
  countUnreadNotifications 
} = require('../controllers/notificationsController');

router.post('/send-notification', createNotification);
router.get('/count-unread/:adminId', countUnreadNotifications); 
router.get('/:adminId', getNotifications); 
router.put('/read/:notificationId', markAsRead);
router.delete('/delete/:notificationId', deleteNotification);

module.exports = router;
