import 'package:flutter/material.dart';
import 'features/traveler/screens/traveler_dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TRAVGO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F8FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
          secondary: const Color(0xFF14B8A6),
          surface: const Color(0xFFFFFFFF),
        ),
      ),
      home: const TravelerDashboardScreen(),
    );
  }
}

