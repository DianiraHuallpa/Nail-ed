import type { Timestamp } from 'firebase-admin/firestore';

import type { Tramo, Servicio } from './common';

export type IntervaloCitas = 15 | 30 | 60;

export interface Negocio {
  uid: string; // igual al ID del documento y al del profesional
  id: number; // ID incremental
  nombre: string;
  ubicacion: string;
  image?: string;
  servicios: Servicio[];
  horarios: {
    lunes: Tramo;
    martes: Tramo;
    miercoles: Tramo;
    jueves: Tramo;
    viernes: Tramo;
    sabado: Tramo;
    domingo: Tramo;
  };
  intervaloCitas?: IntervaloCitas;
  diasNoDisponibles?: string[];
  descripcionNegocio: string;
  terminosCondiciones: string;
  cancelacionHoras: number;
  deleted: boolean;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
