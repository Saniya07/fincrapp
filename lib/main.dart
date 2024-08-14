import 'package:flutter/material.dart';
import 'package:fincr/pages/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://aobzyijbbfxncpyqpeae.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFvYnp5aWpiYmZ4bmNweXFwZWFlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjIxNTIzODMsImV4cCI6MjAzNzcyODM4M30.2iqAxSnBr1EFmNlVrN-u6PB69hUUF5kCuAw6_KyZbfg",
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
