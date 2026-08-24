import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://ctphbschgxbvnajxznbp.supabase.co';
  static const String supabasePublishableKey =  'sb_publishable_z2sj1VMCFbAn8ymXNc-t_Q_12eJbTUb';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabasePublishableKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}