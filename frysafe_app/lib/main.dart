after i import 'package:flutter/material.dart';
import 'screens/app_shell.dart';
import 'services/device_service.dart';
import 'theme/app_theme.dart';

void main() {
  DeviceService.instance; // creates the shared mock data (readings, alerts...) first
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ODI',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
      ),
      // Keeps the app phone-sized when you test in Chrome
      builder: (context, child) => ColoredBox(
        color: const Color(0xFF2B2B2B),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: child,
          ),
        ),
      ),
      home: const AppShell(),
    );
  }
}
