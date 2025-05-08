import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nail_ed/presentation/screen/InicioSesion.dart';
import 'package:nail_ed/presentation/utils/navigation_helpers.dart';
import '../../theme.dart';

/// Clase que representa la pantalla de recuperación de contraseña
class RecuperarContrasena extends StatefulWidget {
  const RecuperarContrasena({super.key});

  @override
  State<RecuperarContrasena> createState() => _RecuperarContrasenaState();
}

class _RecuperarContrasenaState extends State<RecuperarContrasena> {
  final TextEditingController _emailController = TextEditingController();
  /// Control de carga
  bool _loading = false;

  /// Método para enviar instrucciones de recuperación de contraseña
  Future<void> _enviarInstrucciones() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, introduce tu correo electrónico.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se han enviado las instrucciones a tu correo.'),
          backgroundColor: nailAppPink,
        ),
      );
      clearAngGo(InicioSesion());
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error al enviar el correo';
      if (e.code == 'user-not-found') {
        mensaje = 'No se encontró una cuenta con ese correo.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: nailAppPink,
        title: Text('Recuperar Contraseña',
            style: GoogleFonts.italiana(fontSize: 26)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              Text(
                'Introduce tu email para enviarte un enlace de recuperación.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 16),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon:
                      const Icon(Icons.email_outlined, color: nailAppPink),
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _enviarInstrucciones,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Enviar instrucciones',
                          style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
