import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nail_ed/models/negocio.dart';
import 'package:nail_ed/presentation/screen/Cliente/ReservaCitaPaso2.dart';
import 'package:nail_ed/presentation/utils/navigation_helpers.dart';
import 'package:nail_ed/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Clase que representa el primer paso en el proceso de reserva de una cita.
/// 
/// Esta clase es un widget con estado que permite al usuario interactuar 
/// con la interfaz para seleccionar el negocio donde desea realizar la cita.
class ReservaCitaPaso1 extends StatefulWidget {
  const ReservaCitaPaso1({super.key});

  @override
  State<ReservaCitaPaso1> createState() => _ReservaCitaPaso1State();
}

class _ReservaCitaPaso1State extends State<ReservaCitaPaso1> {
  List<QueryDocumentSnapshot> _manicuristasDocs = [];
  QueryDocumentSnapshot? _manicuristaSeleccionada;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchManicuristas();
  }

  /// Obtiene la lista de manicuristas desde Firestore
  Future<void> _fetchManicuristas() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('negocios')
          .where('deleted', isEqualTo: false)
          .get();

      setState(() {
        _manicuristasDocs = snapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Maneja la acción cuando se presiona el botón "Buscar"
  void _onBuscarPressed() {
    if (_manicuristaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, selecciona una manicurista antes de continuar.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      navigateTo(
        ReservaCitaPaso2(
          negocio: Negocio.fromJson(
            _manicuristaSeleccionada!.data() as Map<String, dynamic>,
          ),
        ),
      );
    }
  }

  /// Construye el menú desplegable para seleccionar una manicurista
  Widget _buildManicuristaDropdown() {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }

    return DropdownButtonFormField<QueryDocumentSnapshot>(
      value: _manicuristaSeleccionada,
      decoration: InputDecoration(
        labelText: 'Selecciona a tu manicurista',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.search, color: nailAppPink),
      ),
      items: _manicuristasDocs.map((doc) {
        final nombre = doc['nombre']; // Reemplazar con el campo correcto
        return DropdownMenuItem(
          value: doc,
          child: Text(nombre),
        );
      }).toList(),
      onChanged: (doc) {
        setState(() {
          _manicuristaSeleccionada = doc;
        });
      },
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                Text(
                  'Reserva tu cita paso 1:',
                  style: GoogleFonts.italiana(
                    textStyle: const TextStyle(fontSize: 30),
                    color: nailAppPink,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Busca a tu manicurista:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 24),

                // Menú desplegable para seleccionar una manicurista
                _buildManicuristaDropdown(),
                const SizedBox(height: 24),

                // Botón de búsqueda
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onBuscarPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Buscar',
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
