import 'package:flutter/material.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
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
