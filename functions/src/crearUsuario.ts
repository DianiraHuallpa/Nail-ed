import * as functions from 'firebase-functions';
import { to } from 'await-to-js';
import { Timestamp } from 'firebase-admin/firestore';

import { auth, db } from './app'; // <-- Asegúrate que tienes `auth` y `db` inicializados
import type { Usuario } from './types/users';
import type { Negocio } from './types/negocios';

interface InputDataCliente
  extends Omit<Usuario, 'uid' | 'id' | 'fcmToken' | 'deleted' | 'createdAt' | 'updatedAt'> {
  email: string;
  password: string;
  rol: 'cliente';
}

interface InputDataProfesional
  extends Omit<Usuario, 'uid' | 'id' | 'fcmToken' | 'deleted' | 'createdAt' | 'updatedAt'> {
  email: string;
  password: string;
  rol: 'profesional';
  nombreNegocio: string;
  ubicacionNegocio: string;
}

type InputData = InputDataCliente | InputDataProfesional;

export const crearUsuario = functions
  .runWith({
    minInstances: 1,
    allowInvalidAppCheckToken: true,
  })
  .https.onCall(async (data: InputData) => {
    // eslint-disable-next-line no-console
    console.log(data);
    // Validar datos de entrada mínimos
    const { email, password, nombre, apellidos, edad, telefono, rol } = data;
    if (!email || !password || !nombre || !apellidos || !rol) {
      throw new Error('Datos incompletos para crear el usuario');
    }

    if (rol === 'profesional') {
      if (!data.nombreNegocio || !data.ubicacionNegocio) {
        throw new Error('Los profesionales deben incluir datos de negocio válidos');
      }
    }

    // Crear usuario en Firebase Authentication
    const [createUserError, userRecord] = await to(
      auth.createUser({
        email,
        password,
        displayName: `${nombre} ${apellidos}`,
      }),
    );
    if (createUserError || !userRecord) {
      throw new Error('Error creando usuario en Authentication: ' + createUserError?.message);
    }

    const uid = userRecord.uid;
    const [setCustomUserClaimsError] = await to(auth.setCustomUserClaims(uid, { rol }));
    if (setCustomUserClaimsError) {
      throw new Error('Error seteando permisos: ' + setCustomUserClaimsError?.message);
    }

    const [transactionError] = await to(
      db.runTransaction(async (transaction): Promise<void> => {
        // Buscar el último ID incremental de usuarios
        const [maxUserIdError, maxUserSnap] = await to(
          transaction.get(db.collection('usuarios').orderBy('id', 'desc').select('id').limit(1)),
        );
        if (maxUserIdError) {
          throw new Error('Error obteniendo el último ID de usuario');
        }
        const maxId = maxUserSnap?.empty ? 0 : (maxUserSnap.docs[0].data().id as number);

        // Crear documento de Usuario
        const usuarioRef = db.collection('usuarios').doc(uid);
        const usuarioData: Usuario = {
          uid,
          id: maxId + 1,
          nombre,
          apellidos,
          edad: Number(edad),
          telefono,
          email,
          rol,
          deleted: false,
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        };

        transaction.set(usuarioRef, usuarioData);

        // Si el usuario es profesional, también crear su negocio
        if (rol === 'profesional') {
          const negocioRef = db.collection('negocios').doc(uid);
          const negocioData: Negocio = {
            uid,
            id: maxId + 1,
            nombre: data.nombreNegocio,
            ubicacion: data.ubicacionNegocio,
            servicios: [],
            horarios: {
              lunes: {
                horaInicio: '00:00',
                horaFin: '00:00',
              },
              martes: {
                horaInicio: '00:00',
                horaFin: '00:00',
              },
              miercoles: {
                horaInicio: '00:00',
                horaFin: '00:00',
              },
              jueves: {
                horaInicio: '00:00',
                horaFin: '00:00',
              },
              viernes: {
                horaInicio: '00:00',
                horaFin: '00:00',
              },
              sabado: {
                horaInicio: '00:00',
                horaFin: '00:00',
              },
              domingo: {
                horaInicio: '00:00',
                horaFin: '00:00',
              },
            },
            intervaloCitas: 30,
            diasNoDisponibles: [],
            descripcionNegocio: '',
            terminosCondiciones: '',
            cancelacionHoras: 24,
            deleted: false,
            createdAt: Timestamp.now(),
            updatedAt: Timestamp.now(),
          };

          transaction.set(negocioRef, negocioData);
        }
      }),
    );
    if (transactionError) {
      throw new Error('Error creando el usuario en Firestore: ' + transactionError?.message);
    }

    return { success: true, uid };
  });
