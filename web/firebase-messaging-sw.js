importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

// Configuración de Firebase
firebase.initializeApp({
  apiKey: "AIzaSyDUNMcAX69F21sIcGK7117jSqJdwvAOaOQ",
  authDomain: "nail-ed.firebaseapp.com",
  projectId: "nail-ed",
  storageBucket: "nail-ed.appspot.com", // ⚡ Corrección aquí: el dominio de storage era incorrecto
  messagingSenderId: "229424533122",
  appId: "1:229424533122:web:2a82c5d7d7299aab8d2e9b",
});

// Inicializar Messaging
const messaging = firebase.messaging();

// Escuchar mensajes en background
messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Background message recibido:', payload);

  const notificationTitle = payload.notification?.title || 'Nueva Notificación';
  const notificationOptions = {
    body: payload.notification?.body || 'Tienes una nueva actualización.',
    icon: '/icons/Icon-192.png', // Icono opcional
    data: {
      url: payload.data?.click_action || '/', // Redirección al hacer click
    },
  };

  // Mostrar la notificación
  self.registration.showNotification(notificationTitle, notificationOptions);
});

// Gestionar clicks en las notificaciones
self.addEventListener('notificationclick', function(event) {
  console.log('[firebase-messaging-sw.js] Click en la notificación', event.notification);

  event.notification.close();

  const clickActionUrl = event.notification.data?.url || '/';

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function(clientList) {
      for (const client of clientList) {
        if (client.url.includes(clickActionUrl) && 'focus' in client) {
          return client.focus();
        }
      }
      if (clients.openWindow) {
        return clients.openWindow(clickActionUrl);
      }
    }),
  );
});