import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nail_ed/models/negocio.dart';
import 'package:nail_ed/models/servicio.dart';
import 'package:nail_ed/presentation/screen/DashboardClienteLista.dart';
import 'package:nail_ed/presentation/utils/navigation_helpers.dart';
import 'package:nail_ed/theme.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';


/// Clase que representa el segundo y ultimo paso en el proceso de reserva de una cita.
/// 
/// Esta clase es un widget con estado que permite al usuario seleccionar un servicio
/// y una fecha/hora para su cita. Recibe como parámetro el negocio seleccionado
/// en el paso anterior.
class ReservaCitaPaso2 extends StatefulWidget {
  final Negocio negocio;
  const ReservaCitaPaso2({super.key, required this.negocio});

  @override
  State<ReservaCitaPaso2> createState() => _ReservaCitaPaso2State();
}

class _ReservaCitaPaso2State extends State<ReservaCitaPaso2> {
  /// Negocio seleccionado por el usuario.
  late Negocio? _negocio;
  /// Servicio seleccionado por el usuario.
  String? _horarioSeleccionado;
  /// Servicio seleccionado por el usuario.
  Servicio? _servicioSeleccionado;
  /// Lista de servicios disponibles en el negocio.
  List<Servicio> _serviciosDisponibles = [];
  /// Fecha y hora marcada por el calendario.
  DateTime _focusedDay = DateTime.now();
  /// Fecha seleccionada por el usuario.
  DateTime? _selectedDay;
  /// Indica si se está cargando la disponibilidad de citas.
  bool _loadingDisponibilidad = false;
  /// Indica si se está cargando la pantalla.
  bool _isLoading = false;
  /// Mapa que contiene la disponibilidad de citas por fecha.
  Map<String, List<String>> disponibilidad = {};

  @override
  void initState() {
    super.initState();
    _negocio = widget.negocio;
    _serviciosDisponibles = _negocio!.servicios;
  }

  /// Metodo que se encarga de obtener la disponibilidad de citas
  /// para el servicio seleccionado en el mes actual
  Future<void> _fetchDisponibilidad() async {
    if (_servicioSeleccionado == null) return;

    setState(() {
      _loadingDisponibilidad = true;
      _selectedDay = null;
      _horarioSeleccionado = null;
    });

    try {
      final firstOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final lastOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
      final callable =
          FirebaseFunctions.instance.httpsCallable('getDisponibilidad');
      final nuevaDisp = await callable.call({
        "negocioId": widget.negocio.uid,
        "duracion": _servicioSeleccionado!.duracion,
        "fechaInicio": firstOfMonth.toIso8601String(),
        "fechaFin": lastOfMonth.toIso8601String(),
      });
      final Map<String, dynamic> intermediate = Map.from(nuevaDisp.data);

      final Map<String, List<String>> mapped =
          intermediate.map((rawKey, value) {
        final lista =
            List<dynamic>.from(value).map((e) => e.toString()).toList();
        return MapEntry(rawKey, lista);
      });

      setState(() {
        disponibilidad = mapped;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error cargando disponibilidad: $e'),
          backgroundColor: Colors.red));
    } finally {
      setState(() {
        _loadingDisponibilidad = false;
      });
    }
  }

  /// Convierte una fecha a una cadena en formato 'YYYY-MM-DD'.
  String _formatDateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Genera una lista de horarios disponibles para la fecha seleccionada.
  List<String> _generarHorariosDisponibles() {
    if (_selectedDay == null) return [];
    return disponibilidad[_formatDateKey(_selectedDay!)] ?? [];
  }

  /// Muestra un diálogo de términos y condiciones antes de crear la cita.
  Future<bool> _mostrarDialogoTerminos() async {
    bool aceptado = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Términos y condiciones'),
          content: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Al confirmar la cita, aceptas las políticas de cancelación y puntualidad.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: aceptado,
                      onChanged: (v) => setState(() => aceptado = v ?? false),
                    ),
                    const Expanded(
                        child: Text('Acepto los términos y condiciones')),
                  ],
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
                if (aceptado) Navigator.pop(ctx);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
    return aceptado;
  }

  /// Crea una cita con los datos seleccionados por el usuario.
  Future<void> _crearCita() async {
    if (_selectedDay == null ||
        _horarioSeleccionado == null ||
        _servicioSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Por favor selecciona un servicio, fecha y hora.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final aceptado = await _mostrarDialogoTerminos();
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
    setState(() {
      _isLoading = true;
    });
    try {
      final partes = _horarioSeleccionado!.split(':');
      final fechaInicio = DateTime(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day,
        int.parse(partes[0]),
        int.parse(partes[1]),
      );
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('crearReserva');
      await callable.call({
        "negocioId": _negocio!.uid,
        "clienteId": user.uid,
        "fechaInicio": fechaInicio.toIso8601String(),
        "servicios": [_servicioSeleccionado!.toJson()],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reserva creada con éxito'),
          backgroundColor: nailAppPink,
        ),
      );
      await Future.delayed(const Duration(seconds: 1));
      clearAngGo(DashboardClienteLista());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Error al crear reserva',
          style: TextStyle(
            color: Colors.red,
          ),
        ),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: nailAppPink,
        centerTitle: true,
        title: Text(
          'Nail-ed', //poner el nombre del negocio de manicurista
          style: GoogleFonts.italiana(
            textStyle: const TextStyle(fontSize: 30),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isLoading,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Título
                        Text(
                          'Reserva tu cita paso 2:',
                          style: GoogleFonts.italiana(
                            textStyle: const TextStyle(fontSize: 30),
                            color: nailAppPink,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Selecciona tu servicio:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 24),

                        DropdownButtonFormField<Servicio>(
                          value: _servicioSeleccionado,
                          decoration: InputDecoration(
                            labelText: 'Selecciona un servicio',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            prefixIcon:
                                const Icon(Icons.search, color: nailAppPink),
                          ),
                          items: _serviciosDisponibles.map((servicio) {
                            return DropdownMenuItem(
                              value: servicio,
                              child: Text(
                                  '${servicio.nombre} • ${servicio.duracion} min • ${servicio.precio.toStringAsFixed(2)} €'),
                            );
                          }).toList(),
                          onChanged: (value) async {
                            setState(() {
                              _servicioSeleccionado = value;
                            });
                            await _fetchDisponibilidad();
                          },
                        ),

                        const SizedBox(height: 24),
                        if (_servicioSeleccionado != null) ...[
                          const Text(
                            'Citas disponibles:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),

                          _loadingDisponibilidad
                              ? SizedBox(
                                  height: 300,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ))
                              : TableCalendar(
                                  locale: 'es_Es',
                                  firstDay: DateTime.now(),
                                  lastDay: DateTime.utc(2025, 12, 31),
                                  focusedDay: _focusedDay,
                                  selectedDayPredicate: (day) =>
                                      isSameDay(_selectedDay, day),
                                  availableCalendarFormats: const {
                                    CalendarFormat.month: 'month',
                                  },
                                  onDaySelected: (day, focused) {
                                    final slots =
                                        disponibilidad[_formatDateKey(day)] ??
                                            [];
                                    if (_servicioSeleccionado == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Selecciona primero un servicio'),
                                              backgroundColor: Colors.red));
                                      return;
                                    }
                                    if (slots.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'No hay disponibilidad ese día'),
                                              backgroundColor: Colors.red));
                                      return;
                                    }
                                    setState(() {
                                      _selectedDay = day;
                                      _focusedDay = focused;
                                      _horarioSeleccionado = null;
                                    });
                                  },
                                  onPageChanged: (focusedDay) async {
                                    setState(() {
                                      _focusedDay = focusedDay;
                                    });
                                    await _fetchDisponibilidad();
                                  },
                                  calendarBuilders: CalendarBuilders(
                                    defaultBuilder: (context, day, _) {
                                      final slots =
                                          disponibilidad[_formatDateKey(day)] ??
                                              [];
                                      final disponible = slots.isNotEmpty;
                                      return Container(
                                        margin: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: disponible
                                                ? Colors.green
                                                : Colors.red,
                                            width: 2,
                                          ),
                                          shape: BoxShape.rectangle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${day.day}',
                                          style: TextStyle(
                                            color: disponible
                                                ? Colors.black
                                                : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    },
                                    todayBuilder: (context, day, _) {
                                      return Container(
                                        margin: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: nailAppPink, width: 2),
                                          color: nailAppPinkBack,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text('${day.day}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      );
                                    },
                                  ),
                                  calendarStyle: const CalendarStyle(
                                    outsideDaysVisible: false,
                                  ),
                                ),

                          if (_selectedDay != null &&
                              _servicioSeleccionado != null) ...[
                            const SizedBox(height: 24),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _generarHorariosDisponibles().map((h) {
                                final sel = _horarioSeleccionado == h;
                                return ChoiceChip(
                                  label: Text(h),
                                  selected: sel,
                                  onSelected: (_) =>
                                      setState(() => _horarioSeleccionado = h),
                                  selectedColor: nailAppPink,
                                  labelStyle: TextStyle(
                                      color: sel ? Colors.white : Colors.black),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 32),
                          ],

                          const SizedBox(height: 32),

                          // Botón confirmar cita
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _crearCita,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text(
                                'Confirmar cita',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            const Opacity(
              opacity: 0.5,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: Colors.white,
        foregroundColor: nailAppPink,
        overlayOpacity: 0.3,
        spaceBetweenChildren: 12,
        spacing: 16,
        direction: SpeedDialDirection.up,
        children: [
          // -- Información de la manicurista --
          SpeedDialChild(
            child: const Icon(Icons.info_outline, color: nailAppPink),
            label: 'Información de la manicurista',
            onTap: () {
              final n = widget.negocio;
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Información de la manicurista'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nombre: ${n.nombre}'),
                      const SizedBox(height: 8),
                      Text('Ubicación: ${n.ubicacion}'),
                      const SizedBox(height: 8),
                      const Text('Descripción:'),
                      Text(n.descripcionNegocio),
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
            },
          ),

          // -- Términos y condiciones --
          SpeedDialChild(
            child: const Icon(Icons.warning_amber_outlined, color: nailAppPink),
            label: 'Términos y condiciones',
            onTap: () {
              final n = widget.negocio;
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Términos y condiciones'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Condiciones:'),
                      Text(n.terminosCondiciones),
                      const SizedBox(height: 16),
                      Text('Cancelación: ${n.cancelacionHoras} horas antes.'),
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
            },
          ),
        ],
      ),
    );
  }
}
