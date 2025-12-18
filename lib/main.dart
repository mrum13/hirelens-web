import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hirelens_admin/router.dart';
import 'package:hirelens_admin/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Load environment variables (.env harus di root & ditambahkan ke pubspec.yaml)
  await dotenv.load(fileName: ".env");

  // ✅ Debug print buat pastikan .env terbaca
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  print('==============================');
  print('Supabase URL   : $supabaseUrl');
  print('Anon Key Loaded: ${supabaseAnonKey != null ? "Yes ✅" : "No ❌"}');
  print('==============================');

  // ✅ Cek error kalau .env kosong
  if (supabaseUrl == null ||
      supabaseUrl.isEmpty ||
      supabaseAnonKey == null ||
      supabaseAnonKey.isEmpty) {
    throw Exception(
      '❌ Gagal memuat SUPABASE_URL atau SUPABASE_ANON_KEY dari file .env',
    );
  }

  // ✅ Initialize Supabase pakai anon key (bukan service_role)
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hirelens Admin',
      debugShowCheckedModeBanner: false,
      theme: hirelensDarkTheme,
      routerConfig: router,
    );
  }
}
