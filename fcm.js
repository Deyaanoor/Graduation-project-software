// fcm.js
const { google } = require('google-auth-library');
const axios = require('axios');
const path = require('path');

const SERVICE_ACCOUNT_PATH = path.join(__dirname, 'firebase', 'firebase-key.json'); // تأكد من مكان الملف

const getAccessToken = async () => {
  const auth = new google.auth.GoogleAuth({
    keyFile: SERVICE_ACCOUNT_PATH,
    scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
  });

  const accessToken = await auth.getAccessToken();
  return accessToken.token;
};

const sendFCMNotification = async (tokens, notification, data = {}) => {
  const accessToken = await getAccessToken();

  const message = {
    message: {
      notification,
      data,
      token: tokens[0] // أرسل لشخص واحد فقط في هذا المثال، أو استخدم 'tokens' مع طريقة أخرى إذا بدك ترسل لمجموعة
    }
  };

  await axios.post(
    'https://fcm.googleapis.com/v1/projects/graduation-notifications/messages:send',
    message,
    {
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
    }
  );
};

module.exports = { sendFCMNotification };
