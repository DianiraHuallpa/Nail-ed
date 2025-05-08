import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nail_ed/models/usuario.dart';
import 'package:nail_ed/presentation/screen/DashboardClienteLista.dart';
import 'package:nail_ed/presentation/utils/navigation_helpers.dart';
import '../../../theme.dart';

/// La clase `ModificarDatosPersonales` es un widget con estado que permite
/// a los usuarios modificar sus datos personales dentro de la aplicación.
/// 
/// Esta clase forma parte de la capa de presentación y está diseñada para
/// proporcionar una interfaz interactiva donde los usuarios puedan actualizar
/// información como nombre y apellidos entre otros.
class ModificarDatosPersonales extends StatefulWidget {
  final Usuario usuario;
  const ModificarDatosPersonales({super.key, required this.usuario});

  @override
  State<ModificarDatosPersonales> createState() =>
      _ModificarDatosPersonalesState();
}

class _ModificarDatosPersonalesState extends State<ModificarDatosPersonales> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  /// Inicializa los controladores con los datos del usuario
  void _initializeControllers() {
    final usuario = widget.usuario;
    _nombreController.text = usuario.nombre;
    _apellidosController.text = usuario.apellidos;
    _edadController.text = usuario.edad.toString();
    _telefonoController.text = usuario.telefono;
  }

  /// Valida los campos y muestra un mensaje de error si es necesario
  bool _validateFields() {
    if (_nombreController.text.trim().isEmpty ||
        _apellidosController.text.trim().isEmpty ||
        _edadController.text.trim().isEmpty ||
        _telefonoController.text.trim().isEmpty) {
      _showSnackBar('Por favor, rellena todos los campos', Colors.red);
      return false;
    }
    return true;
  }

  /// Actualiza los datos del usuario en Firestore
  Future<void> _updateUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({
          "nombre": _nombreController.text.trim(),
          "apellidos": _apellidosController.text.trim(),
          "edad": int.parse(_edadController.text.trim()),
          "telefono": _telefonoController.text.trim(),
        });

        _showSnackBar('Datos actualizados con éxito', nailAppPink);
        await Future.delayed(const Duration(seconds: 1));
        clearAngGo(DashboardClienteLista());
      }
    } catch (e) {
      _showSnackBar('Error al actualizar datos', Colors.red);
    }
  }

  /// Muestra un mensaje en pantalla
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: color),
        ),
      ),
    );
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Título
                  Text(
                    'Gestiona tu información, ${widget.usuario.nombre}',
                    style: GoogleFonts.italiana(
                      textStyle: const TextStyle(fontSize: 30),
                      color: nailAppPink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Información personal',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Campos de texto
                  _buildTextField(
                    controller: _nombreController,
                    label: 'Nombre',
                    icon: Icons.person_2,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _apellidosController,
                    label: 'Apellidos',
                    icon: Icons.badge,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _edadController,
                    label: 'Edad',
                    icon: Icons.cake,
                    keyboardType: TextInputType.number,
                    hintText: 'Tienes que ser mayor de 18 años',
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _telefonoController,
                    label: 'Número de teléfono',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    hintText: '+34 600 123 456',
                  ),
                  const SizedBox(height: 32),

                  // Botón Guardar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_validateFields()) {
                          await _updateUserData();
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
        ),
      ),
    );
  }

  // Construye un campo de texto reutilizable
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: nailAppPink),
        labelText: label,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _edadController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }
}
