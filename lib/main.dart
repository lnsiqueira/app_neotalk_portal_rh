import 'package:app_neotalk_portal_rh/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeoBen - Benefícios Corporativos',
      theme: AppTheme.theme,
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
