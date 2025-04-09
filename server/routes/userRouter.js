const express = require('express');
const { registerUser, loginUser, updateAvatar, upload, getUserInfo, updateUserInfo } = require('../controllers/userController');
const router = express.Router();
const authMiddleware = require('../middleware/userMidd');

router.post('/register', registerUser);

router.post('/login', loginUser);

router.post('/update-avatar', upload.single('avatar'), updateAvatar);

router.get('/get-user-info/:userId', getUserInfo);  // هذا المسار لا يحتاج إلى authMiddleware

router.put('/update-user-info', updateUserInfo);

router.get('/user-data', authMiddleware, getUserInfo);  // هذا المسار يحتاج إلى authMiddleware

module.exports = router;
