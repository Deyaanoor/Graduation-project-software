// firebase/firebase-config.js

const admin = require("firebase-admin");
const path = require("path");

// const serviceAccount = require(path.resolve(__dirname, "./firebase-key.json"));
const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
  console.log("✅ Firebase admin initialized");
}

module.exports = admin;
