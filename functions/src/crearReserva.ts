import * as functions from 'firebase-functions';
import { to } from 'await-to-js';
import { Timestamp } from 'firebase-admin/firestore';

import { db } from './app';
import type { Reserva } from './types/reservas';
import type { Negocio } from './types/negocios';
import { getDiaSemana } from './lib/utils';

interface InputData {
  negocioId: string;
  clienteId: string;
  fechaInicio: string;
  servicios: {
    nombre: string;
    precio: number;
    duracion: number;
  }[];
  notas?: string;
}

export const crearReserva = functions.runWith({
    allowInvalidAppCheckToken: true,
  }).https.onCall(async (data: InputData, context) => {
  // eslint-disable-next-line no-console
  console.log(data);
  const modoNegocio = context.auth?.uid === data.negocioId;
  if (!context || !context.auth?.uid || (context.auth?.uid !== data.clienteId && !modoNegocio)) {
    throw new Error('No autorizado');
  }

  const { negocioId, clienteId, fechaInicio, servicios, notas } = data;
  if (!negocioId || !clienteId || !fechaInicio || !servicios?.length) {
    throw new Error('Datos incompletos');
  }

  const [transactionError, transactionSuccess] = await to(
    db.runTransaction(async (transaction): Promise<string> => {
      const negocioRef = db.collection('negocios').doc(negocioId);
      const [getNegocioError, negocioSnap] = await to(transaction.get(negocioRef));
      if (getNegocioError || !negocioSnap?.exists) {
        throw new Error('Negocio no encontrado');
      }
      const clienteRef = db.collection('usuarios').doc(clienteId);
      const [getClienteError, clienteSnap] = await to(transaction.get(clienteRef));
      if (getClienteError || !clienteSnap?.exists) {
        throw new Error('Usuarios no encontrado');
      }

      const diaSemana = getDiaSemana(fechaInicio);
      const fechaReserva = new Date(fechaInicio);
      const fechaStr = fechaReserva.toISOString().split('T')[0];
      const fechaTimestamp = Timestamp.fromDate(fechaReserva);
      const inicioMin = fechaReserva.getTime() / (1000 * 60);
      const costeTotal = servicios.reduce((total, s) => total + s.precio, 0);
      const duracionTotal = servicios.reduce((total, s) => total + s.duracion, 0);

      // Si el que emite la reserva es el negocio, no realizamos validaciones de servicios o horario de apertura
      if (!modoNegocio) {
        // COMPROBAR QUE FECHA Y HORA INDICADA CORRESPONDE A RANGOS CORRECTOS
        const negocio = negocioSnap.data() as Negocio;
        const tramo = negocio.horarios[diaSemana];
        if (tramo.horaInicio === tramo.horaFin) {
          throw new Error('El negocio no trabaja este día');
        }

        const tramoInicio = new Date(`${fechaStr}T${tramo.horaInicio}`).getTime() / (1000 * 60);
        const tramoFin = new Date(`${fechaStr}T${tramo.horaFin}`).getTime() / (1000 * 60);
        const disponible = inicioMin >= tramoInicio && inicioMin + duracionTotal <= tramoFin;

        if (!disponible) {
          throw new Error('El negocio no está disponible a esa hora');
        }

        const serviciosNegocio = negocio.servicios || [];
        if (
          !servicios.every((servicio): boolean => {
            return serviciosNegocio.some(
              (s): boolean =>
                s.nombre === servicio.nombre &&
                s.duracion === servicio.duracion &&
                s.precio === servicio.precio,
            );
          })
        ) {
          throw new Error('El negocio no ofrece alguno de los servicios seleccionados');
        }
      }

      const inicioDia = new Date(fechaInicio);
      inicioDia.setHours(0, 0, 0, 0);
      const [getReservasError, reservasSnap] = await to(
        transaction.get(
          db
            .collection('reservas')
            .where('deleted', '==', false)
            .where('negocioId', '==', negocioId)
            .where('fecha', '>=', Timestamp.fromDate(inicioDia))
            .where(
              'fecha',
              '<',
              Timestamp.fromMillis(fechaReserva.getTime() + 1000 * 60 * duracionTotal),
            ),
        ),
      );

      if (getReservasError) {
        throw new Error('Error verificando disponibilidad');
      }

      const solapada = reservasSnap.docs.some((doc): boolean => {
        const r = doc.data() as Reserva;
        if (r.estado == 'cancelada') {
          return false;
        }
        const rInicio = r.fecha.toDate().getTime() / (1000 * 60);
        const rFin = rInicio + r.duracionTotal;
        return inicioMin < rFin && inicioMin + duracionTotal > rInicio;
      });
      if (solapada) {
        throw new Error('Ese horario ya está ocupado');
      }

      const reservaRef = db.collection('reservas').doc();
      const [getMaxIdError, maxIdSnap] = await to(
        db.collection('reservas').orderBy('id', 'desc').select('id').limit(1).get(),
      );
      if (getMaxIdError) {
        throw new Error('Error obteniendo el máximo ID');
      }

      const maxId = maxIdSnap.empty ? 0 : (maxIdSnap.docs[0].data() as Reserva).id;

      const reserva: Reserva = {
        uid: reservaRef.id,
        id: maxId + 1,
        clienteId,
        negocioId,
        servicios,
        fecha: fechaTimestamp,
        duracionTotal,
        costeTotal,
        estado: 'confirmada',
        notas: notas || '',
        deleted: false,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      };

      transaction.set(reservaRef, reserva);
      return reservaRef.id;
    }),
  );
  if (transactionError) {
    throw new Error(transactionError.message);
  }

  return { reservaId: transactionSuccess };
});
