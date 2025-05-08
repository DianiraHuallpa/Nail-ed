import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'presentation/screen/InicioSesion.dart';
import 'presentation/screen/DashboardClienteLista.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kIsWeb) {
    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider('6LeoxDIrAAAAAGZJ-YJGMwtqRC2dX87BTbzUAS0o'),
    );
  } else {
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
      appleProvider:
          kReleaseMode ? AppleProvider.appAttest : AppleProvider.debug,
    );
  }

  FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);

  runApp(const MyApp());
  await setupFirebaseMessaging();
}

Future<void> setupFirebaseMessaging() async {
  try {
    final messaging = FirebaseMessaging.instance;
    NotificationSettings settings =
        await FirebaseMessaging.instance.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  } catch (e) {
    print('Error configurando Firebase Messaging: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nail-ed',
      locale: const Locale('es', 'ES'),
      supportedLocales: const [
        Locale('es', 'ES'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // home: ModificarDatosNegocio(negocio: negocio),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData) {
            // Usuario autenticado
            return const DashboardClienteLista();
          } else {
            // No autenticado
            return const InicioSesion();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
