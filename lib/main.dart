import 'package:flutter/material.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // Initialisation Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialisation Hive
  await Hive.initFlutter();
  await Hive.openBox('userBox'); // Pour le profil et session
  await Hive.openBox('prefsBox'); // Pour onboarding, thème, etc.
  await Hive.openBox('offlineBox'); // Pour le cache des données

  await themeManager.init();
  runApp(const AcadifyApp());
}

class AcadifyApp extends StatelessWidget {
  const AcadifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeManager,
      builder: (context, mode, child) {
        return MaterialApp.router(
          title: 'Acadify UIECC',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode, 
          routerConfig: appRouter,
        );
      },
    );
  }
}
