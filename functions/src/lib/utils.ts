/**
 * Parses a time string in "HH:MM" format and converts it to the total number of minutes.
 * @param {string} hora - The time string in "HH:MM" format.
 * @returns {number} The total number of minutes.
 */
export function parseHora(hora: string): number {
  const [h, m] = hora.split(':').map(Number);
  return h * 60 + m;
}

/**
 * Converts a total number of minutes into a formatted time string in "HH:MM" format.
 * @param {number} minutos - The total number of minutes to format.
 * @returns {string} A string representing the time in "HH:MM" format.
 */
export function formatHora(minutos: number): string {
  const h = Math.floor(minutos / 60);
  const m = minutos % 60;
  return `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}`;
}

/**
 * Generates an array of date strings in "YYYY-MM-DD" format between two given dates.
 * @param {string} desde - The start date in "YYYY-MM-DD" format.
 * @param {string} hasta - The end date in "YYYY-MM-DD" format.
 * @returns {string[]} An array of date strings in "YYYY-MM-DD" format.
 */
export function getRangoFechas(desde: string, hasta: string): string[] {
  const fechas: string[] = [];
  const current = new Date(desde);
  const end = new Date(hasta);
  while (current <= end) {
    fechas.push(current.toISOString().split('T')[0]);
    current.setDate(current.getDate() + 1);
  }
  return fechas;
}

/**
 * Gets the day of the week for a given date string in "YYYY-MM-DD" format.
 * @param {string} fecha - The date string in "YYYY-MM-DD" format.
 * @returns {string} The name of the day of the week in lowercase (e.g., "lunes").
 */
export function getDiaSemana(
  fecha: string,
): 'lunes' | 'martes' | 'miercoles' | 'jueves' | 'viernes' | 'sabado' | 'domingo' {
  return new Date(fecha).toLocaleDateString('es-ES', { weekday: 'long' }).toLowerCase()
    .replaceAll('á', 'a')
    .replaceAll('é', 'e') as
    | 'lunes'
    | 'martes'
    | 'miercoles'
    | 'jueves'
    | 'viernes'
    | 'sabado'
    | 'domingo';
}
