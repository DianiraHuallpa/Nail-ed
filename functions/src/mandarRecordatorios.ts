import * as functions from 'firebase-functions';
import { Timestamp } from 'firebase-admin/firestore';
import { to } from 'await-to-js';

import { db, messaging } from './app';
import type { Usuario } from './types/users';
import type { Reserva } from './types/reservas';
import type { Negocio } from './types/negocios';

export const mandarRecordatorios = functions.pubsub
  .schedule('0 14 * * *')
  .timeZone('Europe/Madrid')
  .onRun(async () => {
    const ahora = new Date();
    const manana = new Date(ahora);
    manana.setDate(manana.getDate() + 1);

    const inicio = new Date(manana);
    inicio.setHours(0, 0, 0, 0);
    const fin = new Date(manana);
    fin.setHours(23, 59, 59, 999);

    const [err, snap] = await to(
      db
        .collection('reservas')
        .where('deleted', '==', false)
        .where('estado', '==', 'confirmada')
        .where('fecha', '>=', Timestamp.fromDate(inicio))
        .where('fecha', '<=', Timestamp.fromDate(fin))
        .select('clienteId', 'negocioId', 'fecha')
        .get(),
    );

    if (err || !snap) {
      throw err;
    }
    console.log(snap.size);

    const reservas = snap.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    })) as (Pick<Reserva, 'negocioId' | 'clienteId' | 'fecha'> & {
      id: string;
    })[];
    for (const reserva of reservas) {
      const [usuarioErr, usuarioSnap] = await to(
        db.collection('usuarios').doc(reserva.clienteId).get(),
      );
      if (usuarioErr || !usuarioSnap.exists) {
        continue;
      }

      const usuario = usuarioSnap.data() as Usuario;
      if (!usuario?.fcmToken) {
        continue;
      }

      const [negocioErr, negocioSnap] = await to(
        db.collection('negocios').doc(reserva.negocioId).get(),
      );
      if (negocioErr || !negocioSnap.exists) {
        continue;
      }
      const negocio = negocioSnap.data() as Negocio;

      await to(
        Promise.all(
          usuario.fcmToken.map((token) => {
            console.log(token);
            messaging.send({
              token,
              notification: {
                title: 'Recordatorio de tu cita',
                body:
                  `Mañana tienes una cita en ${negocio.nombre} a las ` +
                  `${reserva.fecha.toDate().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}`,
              },
              data: {
                tipo: 'recordatorio',
                reservaId: reserva.id,
              },
            });
          }),
        ),
      );
    }
  });
