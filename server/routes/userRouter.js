const express = require('express');
const { registerUser, loginUser, updateAvatar, upload, getUserInfo, updateUserInfo ,addEmployee } = require('../controllers/userController');
const router = express.Router();


router.post('/register', registerUser);
router.post('/login', loginUser);

router.get('/get-user-info/:userId', getUserInfo);  

router.put('/update-user-info/:userId', updateUserInfo);


router.put('/updateAvatar/:userId', upload.single('avatar'), updateAvatar);
module.exports = router;
