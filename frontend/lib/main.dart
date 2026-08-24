import 'package:flutter/material.dart';
import 'config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseConfig.initialize();

  runApp(const TravgoApp());
}

class TravgoApp extends StatelessWidget {
  const TravgoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TRAVGO',
      home: Scaffold(
        body: Center(
          child: Text('TRAVGO connected to Supabase'),
        ),
      ),
    );
  }
}