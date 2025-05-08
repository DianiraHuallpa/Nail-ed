import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nail_ed/models/negocio.dart';
import 'package:nail_ed/models/servicio.dart';
import 'package:nail_ed/models/tramo.dart';
import 'package:nail_ed/presentation/screen/DashboardClienteLista.dart';
import 'package:nail_ed/presentation/utils/navigation_helpers.dart';
import '../../../theme.dart';

/// La clase `ModificarDatosNegocio` es un widget con estado que permite
/// a los propietarios de negocios modificar la información de su negocio
/// dentro de la aplicación.
/// 
/// Recibe un objeto `Negocio` como parámetro y permite editar campos
/// como nombre, ubicación, servicios ofrecidos, horarios de atención,
/// términos y condiciones, entre otros.
class ModificarDatosNegocio extends StatefulWidget {
  final Negocio negocio;
  const ModificarDatosNegocio({super.key, required this.negocio});

  @override
  State<ModificarDatosNegocio> createState() => _ModificarDatosNegocioState();
}

class _ModificarDatosNegocioState extends State<ModificarDatosNegocio> {
  final TextEditingController _nombreNegocioController =
      TextEditingController();
  final TextEditingController _ubicacionNegocioController =
      TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _terminosController = TextEditingController();
  final TextEditingController _nombreServicioController =
      TextEditingController();
  final TextEditingController _duracionServicioController =
      TextEditingController();
  final TextEditingController _precioServicioController =
      TextEditingController();

  String? _intervaloSeleccionado;
  final List<String> _intervalosDisponibles = [
    '15 min',
    '30 min',
    '45 min',
    '1 hora',
    '2 horas'
  ];

  String? _cancelacionSeleccionada;
  final List<String> _cancelacionDisponible = ['24 horas', '48 horas'];

  List<Servicio> _servicios = [];
  bool _mostrarFormularioServicio = false;
  final Map<String, TextEditingController> _horaInicioControllers = {};
  final Map<String, TextEditingController> _horaFinControllers = {};

  final List<String> _diasSemana = [
    'lunes',
    'martes',
    'miercoles',
    'jueves',
    'viernes',
    'sabado',
    'domingo',
  ];

  final List<String> _horasDisponibles = List.generate(24 * 2, (index) {
    final hour = index ~/ 2;
    final minute = (index % 2) * 30;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  });

  @override
  void initState() {
    super.initState();
    final negocio = widget.negocio;
    _nombreNegocioController.text = negocio.nombre;
    _ubicacionNegocioController.text = negocio.ubicacion;
    _descripcionController.text = negocio.descripcionNegocio ?? '';
    _terminosController.text = negocio.terminosCondiciones ?? '';

    if (negocio.intervaloCitas != null) {
      switch (negocio.intervaloCitas) {
        case 15:
          _intervaloSeleccionado = '15 min';
          break;
        case 30:
          _intervaloSeleccionado = '30 min';
          break;
        case 45:
          _intervaloSeleccionado = '45 min';
          break;
        case 60:
          _intervaloSeleccionado = '1 hora';
          break;
        case 120:
          _intervaloSeleccionado = '2 horas';
          break;
      }
    }

    if (negocio.cancelacionHoras != null) {
      switch (negocio.cancelacionHoras) {
        case 24:
          _cancelacionSeleccionada = '24 horas';
          break;
        case 48:
          _cancelacionSeleccionada = '48 horas';
          break;
      }
    }
    if (negocio.servicios.isNotEmpty) {
      _servicios = negocio.servicios;
    }
    for (var dia in _diasSemana) {
      final tramo =
          widget.negocio.horarios?[dia] ?? Tramo(horaInicio: '', horaFin: '');

      _horaInicioControllers[dia] ??=
          TextEditingController(text: tramo.horaInicio);
      _horaFinControllers[dia] ??= TextEditingController(text: tramo.horaFin);
    }
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: SafeArea(
          child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, //
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Título
                Text(
                  'Gestiona tu información',
                  style: GoogleFonts.italiana(
                    textStyle: const TextStyle(fontSize: 30),
                    color: nailAppPink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Negocio',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 32),

                //MOMBRE NEGOCIO
                TextField(
                  controller: _nombreNegocioController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.add_business,
                      color: nailAppPink,
                    ),
                    labelText: 'Nombre de negocio',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24), // Espacio entre campos

                //UBICACION NEGOCIO
                TextField(
                  controller: _ubicacionNegocioController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.maps_home_work,
                      color: nailAppPink,
                    ),
                    labelText: 'Ubicación',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                DropdownButtonFormField<String>(
                  value: _intervaloSeleccionado,
                  decoration: InputDecoration(
                    labelText: 'Intervalo de citas',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.timelapse, color: nailAppPink),
                  ),
                  items: _intervalosDisponibles.map((intervalo) {
                    return DropdownMenuItem(
                      value: intervalo,
                      child: Text(intervalo),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _intervaloSeleccionado = value;
                    });
                  },
                ),

                const SizedBox(height: 32),

                const Text(
                  'Servicios',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                if (_mostrarFormularioServicio) ...[
                  const Text(
                    'Nuevo servicio',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 24),
                  //nombre
                  TextField(
                    controller: _nombreServicioController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      prefixIcon:
                          const Icon(Icons.handshake, color: nailAppPink),
                      labelText: 'Nombre del servicio',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 16),
                  //duracion
                  TextField(
                    controller: _duracionServicioController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.hourglass_bottom,
                          color: nailAppPink),
                      labelText: 'Duración (minutos)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  //precio
                  TextField(
                    controller: _precioServicioController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.euro, color: nailAppPink),
                      labelText: 'Precio (€)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                      onPressed: () {
                        if (_nombreServicioController.text.isNotEmpty &&
                            _duracionServicioController.text.isNotEmpty &&
                            _precioServicioController.text.isNotEmpty) {
                          setState(() {
                            _servicios.add(Servicio(
                              nombre: _nombreServicioController.text.trim(),
                              duracion: int.tryParse(_duracionServicioController
                                      .text
                                      .trim()) ??
                                  0,
                              precio: double.tryParse(
                                      _precioServicioController.text.trim()) ??
                                  0,
                            ));

                            // Limpia los campos
                            _nombreServicioController.clear();
                            _duracionServicioController.clear();
                            _precioServicioController.clear();
                            _mostrarFormularioServicio = false;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: nailAppPink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          )),
                      child: const Text(
                        'Guardar Servicio',
                        style: TextStyle(color: Colors.white),
                      )),
                ],
                Column(
                  children: _servicios.asMap().entries.map((entry) {
                    int index = entry.key;
                    Servicio servicio = entry.value;
                    return ListTile(
                      title: Text(servicio.nombre),
                      subtitle: Text(
                        'Duración: ${servicio.duracion} min - Precio: ${servicio.precio}€',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _servicios.removeAt(index);
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32), // Espacio antes del botón
                const Text(
                  'Horarios de atención',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 16),

                ..._diasSemana.map((dia) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dia[0].toUpperCase() + dia.substring(1),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _horaInicioControllers[dia]!.text.isEmpty
                                  ? null
                                  : _horaInicioControllers[dia]!.text,
                              decoration: const InputDecoration(
                                labelText: 'Inicio (HH:mm)',
                                border: OutlineInputBorder(),
                              ),
                              items: _horasDisponibles.map((h) {
                                return DropdownMenuItem(
                                  value: h,
                                  child: Text(h),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _horaInicioControllers[dia]!.text = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _horaFinControllers[dia]!.text.isEmpty
                                  ? null
                                  : _horaFinControllers[dia]!.text,
                              decoration: const InputDecoration(
                                labelText: 'Fin (HH:mm)',
                                border: OutlineInputBorder(),
                              ),
                              items: _horasDisponibles.map((h) {
                                return DropdownMenuItem(
                                  value: h,
                                  child: Text(h),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _horaFinControllers[dia]!.text = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
                const SizedBox(height: 24),
                const Text(
                  'Descripción de la manicurista',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: _descripcionController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  enableSuggestions: false,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Escribe una descripción breve...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),

                DropdownButtonFormField<String>(
                  value: _cancelacionSeleccionada,
                  decoration: InputDecoration(
                    labelText: 'Margen de cancelacion',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.timelapse, color: nailAppPink),
                  ),
                  items: _cancelacionDisponible.map((intervalo) {
                    return DropdownMenuItem(
                      value: intervalo,
                      child: Text(intervalo),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _cancelacionSeleccionada = value;
                    });
                  },
                ),

                const SizedBox(height: 24),
                const Text('Términos y condiciones',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(
                  controller: _terminosController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  enableSuggestions: false,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Especifica tus políticas, cancelaciones…',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 32), // Espacio antes del botón

                // Botón Continuar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      String nombre = _nombreNegocioController.text.trim();
                      String ubicacion =
                          _ubicacionNegocioController.text.trim();
                      String intervaloStr = _intervaloSeleccionado ?? '';
                      String cancelacionStr = _cancelacionSeleccionada ?? '';
                      String descripcion = _descripcionController.text.trim();
                      String terminos = _terminosController.text.trim();

                      if (nombre.isEmpty ||
                          ubicacion.isEmpty ||
                          intervaloStr.isEmpty ||
                          cancelacionStr.isEmpty ||
                          descripcion.isEmpty ||
                          terminos.isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text(
                            'Por favor, rellena todos los campos',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ));
                        return;
                      }
                      try {
                        int intervalo = 0;
                        switch (intervaloStr) {
                          case '15 min':
                            intervalo = 15;
                            break;
                          case '30 min':
                            intervalo = 30;
                            break;
                          case '45 min':
                            intervalo = 45;
                            break;
                          case '1 hora':
                            intervalo = 60;
                            break;
                          case '2 horas':
                            intervalo = 120;
                            break;
                        }

                        int cancelacion = 24;
                        switch (cancelacionStr) {
                          case '24 horas':
                            cancelacion = 24;
                            break;
                          case '48 horas':
                            cancelacion = 48;
                            break;
                        }

                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          Map<String, Tramo> nuevosHorarios = {};
                          for (var dia in _diasSemana) {
                            nuevosHorarios[dia] = Tramo(
                              horaInicio:
                                  _horaInicioControllers[dia]?.text ?? '',
                              horaFin: _horaFinControllers[dia]?.text ?? '',
                            );
                          }
                          await FirebaseFirestore.instance
                              .collection('negocios')
                              .doc(user.uid)
                              .update({
                            "nombre": nombre,
                            "ubicacion": ubicacion,
                            "intervaloCitas": intervalo,
                            'servicios':
                                _servicios.map((s) => s.toJson()).toList(),
                            'horarios': nuevosHorarios.map(
                                (key, value) => MapEntry(key, value.toJson())),
                            'descripcionNegocio': descripcion,
                            'terminosCondiciones': terminos,
                            'cancelacionHoras': cancelacion
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Datos actualizados con exito'),
                              backgroundColor: nailAppPink,
                            ),
                          );
                          await Future.delayed(const Duration(seconds: 1));
                          clearAngGo(DashboardClienteLista());
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text(
                            'Error al actualizar datos',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Guardar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
      floatingActionButton: SpeedDial(
        backgroundColor: nailAppPink,
        foregroundColor: Colors.white,
        animatedIcon: AnimatedIcons.menu_close,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        spacing: 12,
        spaceBetweenChildren: 8,
        animationCurve: Curves.fastOutSlowIn,
        animationDuration: const Duration(milliseconds: 300),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add),
            label: 'Añadir servicio',
            onTap: () {
              setState(() {
                _mostrarFormularioServicio = true;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nombreNegocioController.dispose();
    _ubicacionNegocioController.dispose();
    _descripcionController.dispose();
    _terminosController.dispose();
    _nombreServicioController.dispose();
    _duracionServicioController.dispose();
    _precioServicioController.dispose();

    for (final controller in _horaInicioControllers.values) {
      controller.dispose();
    }
    for (final controller in _horaFinControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
