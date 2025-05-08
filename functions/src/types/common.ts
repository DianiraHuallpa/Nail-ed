export interface Servicio {
  nombre: string;
  duracion: number; // min
  precio: number;
}

export interface Tramo {
  horaInicio: string; // "10:00"
  horaFin: string; // "14:00"
}
