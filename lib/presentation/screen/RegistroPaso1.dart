import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nail_ed/models/registro.dart';
import 'package:nail_ed/presentation/screen/RegistroPaso2.dart';
import 'package:nail_ed/presentation/utils/navigation_helpers.dart';
import '../../theme.dart';

/// Clase que representa el primer paso en el proceso de registro.
/// 
/// Esta clase es un widget con estado que permite al usuario seleccionar
/// el rol que desea asumir en la aplicación, ya sea como manicurista
/// o cliente
class RegistroPaso1 extends StatefulWidget {
  const RegistroPaso1({super.key});

  @override
  State<RegistroPaso1> createState() => _RegistroPaso1State();
}

class _RegistroPaso1State extends State<RegistroPaso1> {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                Text(
                  'Registrate en Nail-ed',
                  style: GoogleFonts.italiana(
                    textStyle: const TextStyle(fontSize: 30),
                    color: nailAppPink,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),

                // Botón Soy manicurista
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Acción manicurista
                      navigateTo(RegistroPaso2(
                        registroData: RegistroData(rol: 'profesional'),
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Soy manicurista',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Botón Soy cliente
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Acción cliente
                      // Acción manicurista
                      navigateTo(RegistroPaso2(
                        registroData: RegistroData(rol: 'cliente'),
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Soy cliente',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
