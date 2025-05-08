import type { Timestamp } from 'firebase-admin/firestore';

import type { Servicio } from './common';

export type EstadoReserva = 'pendiente' | 'confirmada' | 'cancelada' | 'completada';

export interface Reserva {
  uid: string; // igual al ID del documento
  id: number; // ID incremental
  clienteId: string;
  negocioId: string;
  servicios: Servicio[];
  fecha: Timestamp; // medianoche
  duracionTotal: number; // Suma de servicios
  costeTotal: number; // Suma de costes
  estado: EstadoReserva;
  notas?: string;
  imagenesNotas?: string[];
  notificacionesEnviadas?: string[];
  imagenesResultado?: string[];
  deleted: boolean;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
