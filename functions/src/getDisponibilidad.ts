import * as functions from 'firebase-functions';
import { Timestamp } from 'firebase-admin/firestore';
import { to } from 'await-to-js';

import { db } from './app';
import type { Negocio } from './types/negocios';
import type { Reserva } from './types/reservas';
import { formatHora, getDiaSemana, getRangoFechas, parseHora } from './lib/utils';

interface InputData {
  negocioId: string;
  duracion: number;
  fechaInicio: string;
  fechaFin: string;
}

type OutputData = Record<string, string[]>;

export const getDisponibilidad = functions
  .runWith({
    minInstances: 1,
    allowInvalidAppCheckToken: true,
  })
  .https.onCall(async (data: InputData, context): Promise<OutputData> => {
    // eslint-disable-next-line no-console
    console.log(data);
    if (!context.auth) {
      throw new Error('Debes iniciar sesión.');
    }

    const { negocioId, duracion, fechaInicio, fechaFin } = data;

    if (!negocioId || !fechaInicio || !fechaFin || !duracion) {
      throw new Error('Faltan datos.');
    }

    const [negocioErr, negocioSnap] = await to(db.collection('negocios').doc(negocioId).get());
    if (negocioErr || !negocioSnap?.exists) {
      throw new Error('Negocio no encontrado.');
    }

    const negocio = negocioSnap.data() as Negocio;
    const diasBloqueados = negocio.diasNoDisponibles || [];
    const pasoMinutos = negocio.intervaloCitas || 15;

    const fechaInicioTS = Timestamp.fromDate(new Date(fechaInicio));
    const fechaFinTS = Timestamp.fromDate(new Date(fechaFin));

    const [reservasErr, reservasSnap] = await to(
      db
        .collection('reservas')
        .where('deleted', '==', false)
        .where('negocioId', '==', negocioId)
        .where('fecha', '>=', fechaInicioTS)
        .where('fecha', '<=', fechaFinTS)
        .get(),
    );
    if (reservasErr) {
      throw new Error('Error consultando reservas.');
    }

    const todasReservas = reservasSnap.docs
      .map((doc) => doc.data() as Reserva)
      .filter((r) => ['pendiente', 'confirmada', 'completada'].includes(r.estado));

    const disponibilidad: OutputData = {};
    const fechas = getRangoFechas(fechaInicio, fechaFin);

    for (const fecha of fechas) {
      if (diasBloqueados.includes(fecha)) {
        continue;
      }

      const diaSemana = getDiaSemana(fecha);
      const horariosDia = negocio.horarios[diaSemana];
      if (horariosDia.horaInicio === horariosDia.horaFin) {
        continue;
      }

      const reservasDelDia = todasReservas.filter(
        (r) => r.fecha.toDate().toISOString().split('T')[0] === fecha,
      );

      const huecosDisponibles: string[] = [];
      let cursor = parseHora(horariosDia.horaInicio);
      const fin = parseHora(horariosDia.horaFin);

      while (cursor + duracion <= fin) {
        const actual = formatHora(cursor);
        const startDateTime = new Date(`${fecha}T${actual}`);
        const cursorMinutes = startDateTime.getTime() / (1000 * 60);

        const solapada = reservasDelDia.some((r) => {
          const rInicioMin = r.fecha.toDate().getTime() / (1000 * 60);
          const rFinMin = rInicioMin + r.duracionTotal;
          return cursorMinutes < rFinMin && cursorMinutes + duracion > rInicioMin;
        });

        if (!solapada) {
          huecosDisponibles.push(actual);
        }
        cursor += pasoMinutos;
      }

      if (huecosDisponibles.length > 0) {
        disponibilidad[fecha] = huecosDisponibles;
      }
    }

    return disponibilidad;
  });
