importScripts('https://www.gstatic.com/firebasejs/9.22.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyAOinh9_tjJiKPaFEpephsFZsg2B7arPnE",
  authDomain: "graduation-notifications.firebaseapp.com",
  projectId: "graduation-notifications",
  storageBucket: "graduation-notifications.firebasestorage.app",
  messagingSenderId: "551572470898",
  appId: "1:551572470898:web:497522afe95d673be156eb"
});

const messaging = firebase.messaging();
