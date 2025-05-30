// firebase/firebase-config.js

const admin = require("firebase-admin");
const path = require("path");

const serviceAccount = require(path.resolve(
  __dirname,
  "./graduation-notifications-firebase-adminsdk-fbsvc-32e2c8fc0b"
));

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
  console.log("✅ Firebase admin initialized");
}

module.exports = admin;
