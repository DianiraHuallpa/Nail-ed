import * as admin from 'firebase-admin';

export const app = admin.initializeApp();
export const db = app.firestore();
export const auth = app.auth();
export const storage = app.storage();
export const messaging = admin.messaging();
