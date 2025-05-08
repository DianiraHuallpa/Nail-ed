import 'package:flutter/material.dart';

/// Extensión para facilitar la navegación segura en Flutter.
///
/// Proporciona métodos para navegar entre pantallas asegurándose de que el
/// estado del widget esté montado antes de realizar cualquier operación de navegación.
extension SafeNavigation on State {
  /// Navega a una nueva página.
  ///
  /// Este método utiliza `Navigator.push` para apilar una nueva página en la
  /// pila de navegación.
  ///
  /// - [page]: El widget de la página a la que se desea navegar
  void navigateTo(Widget page) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Reemplaza la página actual con una nueva página.
  ///
  /// Este método utiliza `Navigator.pushReplacement` para reemplazar la página
  /// actual en la pila de navegación con una nueva página.
  ///
  /// - [page]: El widget de la página con la que se desea reemplazar.
  void replaceWith(Widget page) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Limpia toda la pila de navegación y navega a una nueva página.
  ///
  /// Este método utiliza `Navigator.pushAndRemoveUntil` para eliminar todas las
  /// páginas de la pila de navegación y apilar una nueva página como la única
  /// en la pila.
  ///
  /// - [page]: El widget de la página a la que se desea navegar.
  void clearAngGo(Widget page) {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }
}
