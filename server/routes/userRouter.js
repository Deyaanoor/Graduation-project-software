const express = require('express');
const { registerUser, loginUser, 
    updateAvatar, upload, getUserInfo,
     updateUserInfo ,verifyEmail,forgotPassword,renderResetPasswordForm,resetPassword } = require('../controllers/userController');
const router = express.Router();


router.post('/register', registerUser);
router.post('/login', loginUser);

router.get('/get-user-info/:userId', getUserInfo);  

router.put('/update-user-info/:userId', updateUserInfo);
router.get('/verify', verifyEmail);
router.post('/forgot-password', forgotPassword);
router.get('/reset-password', renderResetPasswordForm);
router.post('/reset-password', resetPassword);

router.put('/updateAvatar/:userId', upload.single('avatar'), updateAvatar);
module.exports = router;
