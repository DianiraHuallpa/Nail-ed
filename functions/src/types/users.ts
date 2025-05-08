import type { Timestamp } from 'firebase-admin/firestore';

export type RolUsuario = 'cliente' | 'profesional';

export interface Usuario {
  uid: string; // igual al ID del documento
  id: number; // ID incremental
  nombre: string;
  apellidos: string;
  edad: number;
  telefono: string;
  email: string;
  rol: RolUsuario;
  fcmToken?: string[];
  deleted: boolean;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  lastLogin?: Timestamp;
}
