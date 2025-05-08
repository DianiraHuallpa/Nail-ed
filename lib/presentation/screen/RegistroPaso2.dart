import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nail_ed/models/registro.dart';
import 'package:nail_ed/presentation/screen/RegistroPaso3.dart';
import 'package:nail_ed/presentation/utils/navigation_helpers.dart';
import '../../../theme.dart';

/// Clase que representa el segundo paso en el proceso de registro.
/// 
/// Esta clase es un widget con estado que permite al usuario
/// ingresar información personal como nombre, apellidos, edad,
/// número de teléfono y, si es un profesional, el nombre y ubicación
/// de su negocio.
class RegistroPaso2 extends StatefulWidget {
  /// Datos de registro que se pasan desde el primer paso
  final RegistroData registroData;
  const RegistroPaso2({super.key, required this.registroData});

  @override
  State<RegistroPaso2> createState() => _RegistroPaso2State();
}

class _RegistroPaso2State extends State<RegistroPaso2> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _nombreNegocioController =
      TextEditingController();
  final TextEditingController _ubicacionNegocioController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final registroData = widget.registroData;
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
                    'Registrate en Nail-ed',
                    style: GoogleFonts.italiana(
                      textStyle: const TextStyle(fontSize: 30),
                      color: nailAppPink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crea una cuenta',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 32),

                  //MOMBRE
                  TextField(
                    controller: _nombreController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.person_2,
                        color: nailAppPink,
                      ),
                      labelText: 'Nombre',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24), // Espacio entre campos

                  //APELLIDOS
                  TextField(
                    controller: _apellidosController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.badge,
                        color: nailAppPink,
                      ),
                      labelText: 'Apellidos',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  //Edad
                  TextField(
                    controller: _edadController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.cake,
                        color: nailAppPink,
                      ),
                      labelText: 'Edad',
                      hintText: 'Tienes que ser mayor de 18 años',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Telefono
                  TextField(
                    controller: _telefonoController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.phone,
                        color: nailAppPink,
                      ),
                      labelText: 'Número de teléfono',
                      hintText: '+34 600 123 456',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  if (registroData.rol == 'profesional') ...[
                    const SizedBox(height: 24), // Espacio entre campos
                    //NOMBRE NEGOCIO
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
                        labelText: 'Nombre negocio',
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
                        labelText: 'Ubicacion negocio',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32), // Espacio antes del botón

                  // Botón Continuar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        String nombre = _nombreController.text.trim();
                        String apellidos = _apellidosController.text.trim();
                        String edad = _edadController.text.trim();
                        String telefono = _telefonoController.text.trim();
                        String nombreNegocio =
                            _nombreNegocioController.text.trim();
                        String ubicacionNegocio =
                            _ubicacionNegocioController.text.trim();

                        if (nombre.isEmpty ||
                            telefono.isEmpty ||
                            apellidos.isEmpty ||
                            edad.isEmpty ||
                            (registroData.rol == 'profesional' &&
                                (nombreNegocio.isEmpty ||
                                    ubicacionNegocio.isEmpty))) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                              'Por favor, rellena todos los campos',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ));
                        } else {
                          registroData.nombre = nombre;
                          registroData.apellidos = apellidos;
                          registroData.edad = edad;
                          registroData.telefono = telefono;
                          if (registroData.rol == 'profesional') {
                            registroData.nombreNegocio = nombreNegocio;
                            registroData.ubicacionNegocio = ubicacionNegocio;
                          }
                          navigateTo(RegistroPaso3(registroData: registroData));
                          // Si llega aquí es que ha rellenado los datos correctamente
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('¡A por el correo electrónico!'),
                              backgroundColor: nailAppPink,
                            ),
                          );
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
                        'Continue',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )));
  }
}
