importScripts('https://www.gstatic.com/firebasejs/9.6.10/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.6.10/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyAOinh9_tjJiKPaFEpephsFZsg2B7arPnE",
  authDomain: "graduation-notifications.firebaseapp.com",
  projectId: "graduation-notifications",
  storageBucket: "graduation-notifications.appspot.com",
  messagingSenderId: "551572470898",
  appId: "1:551572470898:web:f7a8b6ea8ab00522e156eb"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);

  const notificationTitle = payload.notification?.title || '📬 إشعار جديد';
  const notificationOptions = {
    body: payload.notification?.body || 'وصل إشعار جديد من التطبيق.',
    icon: '../assets/icon/app_icon.png',
    requireInteraction: true,
    vibrate: [200, 100, 200],
    data: {
      url: '/'
    }
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
