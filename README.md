## 📋 Requisitos Técnicos

Para ejecutar y desplegar este proyecto, asegúrate de tener instaladas las siguientes herramientas:

- **Flutter SDK**: [Instalar Flutter](https://flutter.dev/docs/get-started/install)
- **Dart**: Incluido con Flutter.
- **Android Studio**: Para desarrollo en Android y pruebas en emuladores.
- **Chrome**: Para pruebas en la web.
- **Git**: Sistema de control de versiones para clonar el repositorio.
- **Firebase CLI**: Para gestionar servicios de Firebase.
- **Node.js**: Versión 22 o superior.
- **Yarn**: Para gestionar dependencias del backend.

## 🚀 Funcionalidades

- **Multiplataforma**: Funciona perfectamente en Android e iOS.
- **Integración con Firebase**: Incluye autenticación, base de datos Firestore y almacenamiento en la nube.
- **Interfaz Responsiva**: Se adapta a diferentes tamaños de pantalla y orientaciones.
- **Diseño Moderno**: Interfaz de usuario limpia e intuitiva.

## 🛠️ Ejecución y Depuración

Para ejecutar la aplicación en local para desarrollo o pruebas:

1. Instala las dependencias:
    ```bash
    flutter pub get
    ```

2. Configura un emulador con SDK 35 en Android Studio y selecciónalo como destino de ejecución.

3. Ejecuta la aplicación:
    ```bash
    flutter run
    ```

## 🚀 Despliegue

Para el despliegue de todos los servicios, asegúrate de tener configurado un proyecto de Firebase y haber iniciado sesión con:
```bash
firebase login
```
Selecciona el proyecto configurado con:
```bash
firebase use <proyecto>
```

### Despliegue de la Aplicación Web
1. Construye la aplicación web:
    ```bash
    flutter build web
    ```
2. Despliega la aplicación:
    ```bash
    firebase deploy --only hosting
    ```

### Despliegue de la Aplicación Android
1. Construye el APK:
    ```bash
    flutter build apk
    ```
2. El archivo APK generado estará disponible en la ruta `build/app/outputs/flutter-apk/app-release.apk`.

### Despliegue del Backend
1. Despliega las configuraciones de Firestore:
    ```bash
    firebase deploy --only firestore
    ```
2. Instala las dependencias del backend:
    ```bash
    cd functions
    yarn install
    ```
3. Despliega el backend:
    ```bash
    firebase deploy --only functions
    ```

## 📚 Documentación

- [Documentación de Flutter](https://flutter.dev/docs)
- [Documentación de Firebase](https://firebase.google.com/docs)
- [Lenguaje Dart](https://dart.dev/guides)
