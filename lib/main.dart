import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ SAFE NOTIFICATION STARTUP
  // This try-catch ensures that if alarms fail (like on an emulator),
  // the app will NOT freeze. It will just skip them and load the app!
  try {
    final notificationService = NotificationService();
    await notificationService.init();
    await notificationService.scheduleDailyReminder();
    debugPrint("✅ Notifications initialized successfully.");
  } catch (e) {
    debugPrint("⚠️ Notification setup failed, but app is safe to run: $e");
  }

  runApp(const FarmMateApp());
}

class FarmMateApp extends StatelessWidget {
  const FarmMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FarmMate',
      debugShowCheckedModeBanner: false, // Hides the red "DEBUG" banner
      // ✅ PREMIUM GLOBAL THEME
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,

        // Sets the premium off-white background for the ENTIRE app automatically
        scaffoldBackgroundColor: const Color(0xFFF5F7F5),

        // Global App Bar styling so they all match perfectly
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Global Font styling to look more modern
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),

      home: const LoginScreen(),
    );
  }
}
