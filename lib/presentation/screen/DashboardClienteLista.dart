import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nail_ed/models/negocio.dart';
import 'package:nail_ed/models/reserva.dart';
import 'package:nail_ed/models/usuario.dart';
import 'package:nail_ed/presentation/screen/Cliente/ModificarDatosPersonales.dart';
import 'package:nail_ed/presentation/screen/Cliente/ReservaCitaPaso1.dart';
import 'package:nail_ed/presentation/screen/InicioSesion.dart';
import 'package:nail_ed/presentation/screen/Profesional/ModificarDatosNegocio.dart';
import 'package:nail_ed/presentation/utils/navigation_helpers.dart';
import '../../theme.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Esta clase representa la pantalla principal del cliente donde puede ver
/// sus citas y realizar acciones como cancelar o completar una cita.
/// 
/// La clase utiliza un `StreamBuilder` para escuchar cambios en la base de datos
/// y actualizar la interfaz de usuario en tiempo real.
class DashboardClienteLista extends StatefulWidget {
  const DashboardClienteLista({super.key});

  @override
  State<DashboardClienteLista> createState() => _DashboardClienteState();
}

class _DashboardClienteState extends State<DashboardClienteLista> {
  /// Stream que escucha los cambios en las citas del cliente.
  Stream<List<Map<String, dynamic>>>? citasStream;
  /// Usuario actual.
  Usuario? usuario;
  /// Negocio asociado al usuario actual (si es profesional).
  Negocio? negocio;
  /// Indica si una tarjeta de cita ha sido seleccionada.
  int? _tappedIndex;

  /// Formatea la fecha y hora a UTC con el formato 'dd/MM/yyyy HH:mm'.
  String formatToUtcZero(DateTime dateTime) {
    final utcDate = dateTime.toUtc();
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(utcDate);
  }

  /// Crea un stream que escucha los cambios en las citas del cliente o profesional.
  /// Dependiendo del rol del usuario, se filtran las citas por cliente o negocio.
  Stream<List<Map<String, dynamic>>> _crearCitasStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    final field = usuario?.rol == 'profesional' ? 'negocioId' : 'clienteId';
    return FirebaseFirestore.instance
        .collection('reservas')
        .where('deleted', isEqualTo: false)
        .where(field, isEqualTo: uid)
        .where('estado', isEqualTo: 'confirmada')
        .snapshots()
        .asyncMap((snap) async {
      final List<Map<String, dynamic>> enriched = await Future.wait(
        snap.docs.map((doc) async {
          final data = doc.data();
          final reserva = Reserva.fromJson(data);
          final negocioDoc = await FirebaseFirestore.instance
              .collection('negocios')
              .doc(reserva.negocioId)
              .get();
          final negocio =
              negocioDoc.exists ? Negocio.fromJson(negocioDoc.data()!) : null;

          final userDoc = await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(reserva.clienteId)
              .get();
          final cliente =
              userDoc.exists ? Usuario.fromJson(userDoc.data()!) : null;

          return {
            'reserva': reserva,
            'negocio': negocio,
            'cliente': cliente,
          };
        }),
      );
      return enriched;
    });
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onPressed, int index) {
    return IconButton(
      icon: Icon(icon),
      iconSize: 36,
      splashColor: nailAppPink.withOpacity(0.3),
      onPressed: () {
        setState(() {
          _tappedIndex = index;
        });
        onPressed();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance
        .authStateChanges()
        .firstWhere((u) => u != null)
        .then((user) => _loadUsuario(user!));
  }

  /// Carga el usuario y abre el stream de citas desde Firestore.
  Future<void> _loadUsuario(User user) async {
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      setState(() {
        usuario = Usuario.fromJson(doc.data()!);
      });
      if (usuario?.rol == 'profesional') {
        final doc2 = await FirebaseFirestore.instance
            .collection('negocios')
            .doc(user.uid)
            .get();
        if (doc2.exists) {
          setState(() {
            negocio = Negocio.fromJson(doc2.data()!);
          });
        }
      }
    }
    setState(() {
      citasStream = _crearCitasStream();
    });
  }

  /// Muestra un diálogo de confirmación para cancelar una cita.
  Future<bool> _mostrarDialogoCancelacion() async {
    bool aceptado = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Cancelar'),
          content: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Se procedera a la cancelacion de la cita si los terminos del negocio lo permiten.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                aceptado = true;
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
    return aceptado;
  }

  /// Muestra un diálogo de confirmación para completar una cita.
  Future<bool> _mostrarDialogoCompletar() async {
    bool aceptado = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Completar'),
          content: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Se procedera a marcar la cita como completada.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                aceptado = true;
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
    return aceptado;
  }

  @override
  Widget build(BuildContext context) {
    if (usuario == null || citasStream == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: nailAppPink,
        centerTitle: true,
        title: Text(
          'Nail-ed',
          style: GoogleFonts.italiana(
            textStyle: const TextStyle(fontSize: 30),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              HapticFeedback.lightImpact();
              await FirebaseAuth.instance.signOut();
              clearAngGo(InicioSesion());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mensaje de bienvenida
              Center(
                child: Text(
                  '¡Bienvenid@ de nuevo ${usuario?.nombre ?? ''}!',
                  style: GoogleFonts.italiana(
                    textStyle: const TextStyle(fontSize: 24),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Título citas
              Text(
                'Tus próximas citas:',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                  child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    _tappedIndex = null;
                  });
                },
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: citasStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No tiene citas próximamente',
                          style: GoogleFonts.inter(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }

                    final citas = snapshot.data!;

                    return SizedBox(
                        child: ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: citas.length,
                      itemBuilder: (context, index) {
                        final cita = citas[index];
                        final reserva = cita['reserva'] as Reserva;
                        final negocio = cita['negocio'] as Negocio;
                        final cliente = cita['cliente'] as Usuario;
                        bool isTapped = _tappedIndex == index;
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              if (_tappedIndex == index) {
                                _tappedIndex = null;
                              } else {
                                _tappedIndex =
                                    index;
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isTapped
                                  ? nailAppPink
                                  : (index.isEven
                                      ? nailAppPinkBack
                                      : nailAppPink.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isTapped
                                  ? [
                                      BoxShadow(
                                        color: Colors.black45,
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.person_outline,
                                              color: isTapped
                                                  ? nailAppPinkBack
                                                  : nailAppPink),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              usuario!.rol == 'profesional'
                                                  ? 'Cliente: ${cliente.nombre}'
                                                  : 'Manicurista: ${negocio.nombre}',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today,
                                              color: isTapped
                                                  ? nailAppPinkBack
                                                  : nailAppPink),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${formatToUtcZero(reserva.fecha)}',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.attach_money,
                                              color: isTapped
                                                  ? nailAppPinkBack
                                                  : nailAppPink),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${reserva.costeTotal} €',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Lado derecho: acciones
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildActionIcon(Icons.info_outline,
                                        () => _onInfoTap(cita), index),
                                    _buildActionIcon(Icons.delete,
                                        () => _onCancelarCitaTab(cita), index),
                                    if (usuario?.rol == 'profesional')
                                      _buildActionIcon(
                                          Icons.check_box,
                                          () => _onCompletarCitaTab(cita),
                                          index),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ));
                  },
                ),
              )),
            ],
          ),
        ),
      ),
      floatingActionButton: SpeedDial(
        backgroundColor: Colors.white,
        foregroundColor: nailAppPink,
        animatedIcon: AnimatedIcons.menu_close,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        spacing: 12,
        spaceBetweenChildren: 8,
        animationCurve: Curves.fastOutSlowIn,
        animationDuration: const Duration(milliseconds: 300),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.person, color: nailAppPink),
            backgroundColor: Colors.white,
            label: 'Modificar Datos Personales',
            onTap: () {
              navigateTo(ModificarDatosPersonales(usuario: usuario!));
            },
          ),
          if (usuario?.rol == 'profesional')
            SpeedDialChild(
              child: const Icon(Icons.business, color: nailAppPink),
              backgroundColor: Colors.white,
              label: 'Modificar Datos Negocio',
              onTap: () {
                // llevar a la pantalla de crear cita
                navigateTo(ModificarDatosNegocio(negocio: negocio!));
              },
            ),
          if (usuario?.rol == 'cliente')
            SpeedDialChild(
              child: const Icon(Icons.calendar_today, color: nailAppPink),
              backgroundColor: Colors.white,
              label: 'Nueva cita',
              onTap: () {
                // llevar a la pantalla de crear cita
                navigateTo((ReservaCitaPaso1()));
              },
            ),
        ],
      ),
    );
  }

  Future<void> _onInfoTap(Map<String, dynamic> cita) async {
    final r = cita['reserva'] as Reserva;
    final n = cita['negocio'] as Negocio;
    final c = cita['cliente'] as Usuario;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Información de la manicurista'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (usuario!.rol == 'profesional') ...[
              Text('Nombre: ${c.nombre}'),
              const SizedBox(height: 8),
              Text('Apellidos: ${c.apellidos}'),
              const SizedBox(height: 8),
              Text('Precio: ${r.costeTotal}'),
              const SizedBox(height: 8),
              Text('Duracion: ${r.duracionTotal}'),
              const SizedBox(height: 8),
            ],
            if (usuario!.rol == 'cliente') ...[
              Text('Nombre: ${n.nombre}'),
              const SizedBox(height: 8),
              Text('Ubicación: ${n.ubicacion}'),
              const SizedBox(height: 8),
              const Text('Descripción:'),
              Text(n.descripcionNegocio),
              const Divider(height: 24),
              const Text('Términos y condiciones:'),
              Text(n.terminosCondiciones),
              const SizedBox(height: 8),
              Text('Cancelación: ${n.cancelacionHoras} horas antes'),
            ]
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _onCancelarCitaTab(Map<String, dynamic> cita) async {
    final r = cita['reserva'] as Reserva;

    final aceptado = await _mostrarDialogoCancelacion();
    if (!aceptado) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error con su sesion.'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('cancelarReserva');
      await callable.call({
        "reservaId": r.uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reserva cancelada con éxito'),
          backgroundColor: nailAppPink,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Error al cancelar reserva',
          style: TextStyle(
            color: Colors.red,
          ),
        ),
      ));
    }
  }

  Future<void> _onCompletarCitaTab(Map<String, dynamic> cita) async {
    final r = cita['reserva'] as Reserva;

    final aceptado = await _mostrarDialogoCompletar();
    if (!aceptado) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error con su sesion.'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('completarReserva');
      await callable.call({
        "reservaId": r.uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reserva completada con éxito'),
          backgroundColor: nailAppPink,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Error al completar reserva',
          style: TextStyle(
            color: Colors.red,
          ),
        ),
      ));
    }
  }
}
