import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nail_ed/models/registro.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:nail_ed/presentation/screen/InicioSesion.dart';
import 'package:nail_ed/presentation/utils/navigation_helpers.dart';
import '../../../theme.dart';

/// Clase que representa el tercer paso en el proceso de registro.
///  
/// Esta clase es un widget con estado que permite al usuario
/// ingresar su correo electrónico y contraseña para crear una cuenta.
class RegistroPaso3 extends StatefulWidget {
  /// Datos de registro del usuario
  final RegistroData registroData;
  const RegistroPaso3({super.key, required this.registroData});

  @override
  State<RegistroPaso3> createState() => _RegistroPaso3State();
}

class _RegistroPaso3State extends State<RegistroPaso3> {
  /// Datos de registro del usuario
  late final RegistroData _registroData;
  /// Contraseña oscurecida
  bool _obscurePassword = true;
  /// Contraseña 2 oscurecida
  bool _obscureRepeatPassword = true;
  /// Control de carga
  bool _isLoading = false;

  final TextEditingController _emailRController = TextEditingController();
  final TextEditingController _passwordRController = TextEditingController();
  final TextEditingController _repeatpasswordRController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _registroData = widget.registroData;
  }

  /// Método que se ejecuta al presionar el botón de registro
  Future<void> _onRegistroPressed() async {
    String email = _emailRController.text.trim();
    String password1 = _passwordRController.text.trim();
    String password2 = _repeatpasswordRController.text.trim();
    if (email.isEmpty || password1.isEmpty || password2.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Por favor, rellena todos los campos',
          style: TextStyle(
            color: Colors.red,
          ),
        ),
      ));
      return;
    }
    if (password1 != password2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Las contraseñas no coinciden',
          style: TextStyle(
            color: Colors.red,
          ),
        ),
      ));
      return;
    }
    if (password1.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'La contraseña debe tener al menos 9 caracteres',
          style: TextStyle(
            color: Colors.red,
          ),
        ),
      ));
      return;
    }
    _registroData.email = email;
    _registroData.password = password1;
    setState(() {
      _isLoading = true;
    });
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('crearUsuario');
      await callable.call(_registroData.toJson());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cuenta creada con éxito'),
          backgroundColor: nailAppPink,
        ),
      );
      await Future.delayed(const Duration(seconds: 1));
      clearAngGo(InicioSesion());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Error al crear cuenta',
          // SER MAS ESPECIFICO OCN EL ERROR DE CREACION
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
          'Nail-ed',
          style: GoogleFonts.italiana(
            textStyle: const TextStyle(fontSize: 30),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // ② Tu UI principal, bloqueada cuando _isLoading==true
          AbsorbPointer(
              absorbing: _isLoading,
              child: SafeArea(
                  child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
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

                        //EMail
                        TextField(
                          controller: _emailRController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: nailAppPink,
                            ),
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                        //campo contraseña
                        TextField(
                          controller: _passwordRController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: nailAppPink,
                            ),
                            labelText: 'Constraseña',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: nailAppPink),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // campo repeat pwd
                        TextField(
                          controller: _repeatpasswordRController,
                          obscureText: _obscureRepeatPassword,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: nailAppPink,
                            ),
                            labelText: 'Repite la contraseña',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                  _obscureRepeatPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: nailAppPink),
                              onPressed: () {
                                setState(() {
                                  _obscureRepeatPassword =
                                      !_obscureRepeatPassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 32), // Espacio antes del botón

                        // Botón Continuar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _onRegistroPressed,
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
              ))),
          if (_isLoading)
            const Opacity(
              opacity: 0.5,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
