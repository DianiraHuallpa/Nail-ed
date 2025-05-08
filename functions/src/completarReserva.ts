import * as functions from 'firebase-functions';
import { to } from 'await-to-js';
import { Timestamp } from 'firebase-admin/firestore';

import { db } from './app';
import type { Reserva } from './types/reservas';

interface InputData {
  reservaId: string;
}

interface OutputData {
  success: true;
}

export const completarReserva = functions.runWith({
    allowInvalidAppCheckToken: true,
  }).https.onCall(
  async (data: InputData, context): Promise<OutputData> => {
    // eslint-disable-next-line no-console
    console.log(data);
    if (!context || !context.auth?.uid) {
      throw new Error('No autorizado');
    }

    const { reservaId } = data;
    if (!reservaId) {
      throw new Error('Datos incompletos');
    }

    const [transactionError] = await to(
      db.runTransaction(async (transaction): Promise<void> => {
        const now = Timestamp.now();
        const reservaRef = db.collection('reservas').doc(reservaId);
        const [getReservaError, reservaSnap] = await to(transaction.get(reservaRef));
        if (getReservaError || !reservaSnap?.exists) {
          throw new Error('Reserva no encontrada');
        }
        const reserva = reservaSnap.data() as Reserva;
        if (reserva.negocioId !== context.auth?.uid) {
          throw new Error('No autorizado para completar esta reserva');
        }
        if (reserva.deleted) {
          throw new Error('Reserva eliminada');
        }
        if (reserva.estado === 'completada') {
          throw new Error('Reserva ya completada');
        }

        transaction.update(reservaRef, {
          estado: 'completada',
          updatedDateTime: now,
        });
      }),
    );
    if (transactionError) {
      throw new Error(transactionError.message);
    }

    return { success: true } as OutputData;
  },
);
