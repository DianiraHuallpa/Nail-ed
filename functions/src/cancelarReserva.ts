import * as functions from 'firebase-functions';
import { to } from 'await-to-js';
import { Timestamp } from 'firebase-admin/firestore';

import { db } from './app';
import type { Reserva } from './types/reservas';
import type { Negocio } from './types/negocios';

interface InputData {
  reservaId: string;
}

interface OutputData {
  success: true;
}

export const cancelarReserva = functions
  .runWith({
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
        if (reserva.negocioId !== context.auth?.uid && reserva.clienteId !== context.auth?.uid) {
          throw new Error('No autorizado para cancelar esta reserva');
        }
        if (reserva.deleted) {
          throw new Error('Reserva eliminada');
        }
        if (reserva.estado === 'cancelada') {
          throw new Error('Reserva ya cancelada');
        }

        const modoNegocio = context.auth?.uid === reserva.negocioId;
        if (!modoNegocio) {
          const negocioRef = db.collection('negocios').doc(reserva.negocioId);
          const [getNegocioError, negocioSnap] = await to(transaction.get(negocioRef));
          if (getNegocioError || !negocioSnap?.exists) {
            throw new Error('Negocio no encontrado');
          }
          const negocio = negocioSnap.data() as Negocio;
          if (reserva.fecha.toMillis() - now.toMillis() < negocio.cancelacionHoras * 60 * 60 * 1000) {
            throw new Error('No se puede cancelar la reserva con menos de 24 horas de antelación');
          }
        }
        transaction.update(reservaRef, {
          estado: 'cancelada',
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
