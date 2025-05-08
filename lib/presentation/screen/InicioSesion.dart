import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nail_ed/presentation/screen/DashboardClienteLista.dart';
import 'package:nail_ed/presentation/screen/RegistroPaso1.dart';
import 'package:nail_ed/presentation/screen/RecuperarPassword.dart';
import 'package:nail_ed/presentation/utils/navigation_helpers.dart';
import '../../theme.dart';

/// Clase que representa la pantalla de inicio de sesión
/// 
/// Esta clase es un widget con estado que permite a los usuarios iniciar sesión
/// en la aplicación. Incluye campos para el correo electrónico y la contraseña,
/// así como opciones para recordar la sesión y recuperar la contraseña.
class InicioSesion extends StatefulWidget {
  const InicioSesion({super.key});

  @override
  State<InicioSesion> createState() => _InicioSesionState();
}

class _InicioSesionState extends State<InicioSesion> {
  /// Contraseña oculta
  bool _obscurePassword = true;
  /// Mantener sesión iniciada
  bool _keepSession     = false;
  /// Cargando
  bool _isLoading       = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// Lgoica de inicio de sesión
  Future<void> _onLoginPressed() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, llena todos los campos',
          style: TextStyle(
            color: Colors.red,) ,
        ),
      )
      );
    } else {
      setState(() => _isLoading = true);
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Inicio de sesión exitoso!'),
            backgroundColor: nailAppPink,
          ),
        );
        setState(() => _isLoading = false);
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final now = DateTime.now();
            String? fcmToken;

            NotificationSettings settings = await FirebaseMessaging.instance.getNotificationSettings();
            if (settings.authorizationStatus == AuthorizationStatus.authorized || settings.authorizationStatus == AuthorizationStatus.authorized) {
              fcmToken = await FirebaseMessaging.instance.getToken();
            }
              // Actualizar Firestore
              await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set({
              'lastLogin': now,
              if (fcmToken != null) 'fcmToken': FieldValue.arrayUnion([fcmToken]),
              }, SetOptions(merge: true));
          }
          clearAngGo(const DashboardClienteLista());
        } catch (e) {
          print('Error actualizando lastLogin o fcmToken: $e');
        }
      } on FirebaseAuthException catch (e) {
        String mensajeError = '';

        if (e.code == 'user-not-found') {
          mensajeError = 'No existe un usuario con ese email.';
        } else if (e.code == 'wrong-password') {
          mensajeError = 'Contraseña incorrecta.';
        } else {
          mensajeError = 'Error: ${e.message}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensajeError),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
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
          AbsorbPointer(
            absorbing: _isLoading,
            child: SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Título
                          Text(
                            'Inicia sesión en Nail-ed',
                            style: GoogleFonts.italiana(
                              textStyle: const TextStyle(fontSize: 30),
                              color: nailAppPink,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 50), // Espacio entre título y campos

                          // Campo Usuario
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            enableSuggestions: false,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person_outline, color: nailAppPink,),
                              labelText: 'Usuario o E-mail',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24), // Espacio entre campos

                          // Campo Contraseña
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline, color: nailAppPink,),
                              labelText: 'Contraseña',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                      color: nailAppPink
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
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
                              onPressed: _isLoading ? null : _onLoginPressed,
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
                          const SizedBox( height: 16),
                          //No cerrar sesión y olvidaste contraseña
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _keepSession,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _keepSession = value ?? false;
                                      });
                                    },
                                  ),
                                  const Text('No cerrar sesión'),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  // lógica para recuperar contraseña
                                  navigateTo(RecuperarContrasena());
                                },
                                child: const Text('¿Olvidaste la contraseña?'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 70), // Espacio antes del registro

                          // Crear cuenta
                          const Text(
                            '¿No eres miembro?',
                            style: TextStyle(fontSize: 12),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              navigateTo(RegistroPaso1());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 7),
                            ),
                            child: const Text(
                              'Crea una cuenta',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ),
          ),
          if (_isLoading)
            const Opacity(
              opacity: 0.5,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    ); 
  }
}
