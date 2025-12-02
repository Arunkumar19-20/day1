import 'package:flutter/material.dart';
import 'supervisor_page.dart'; // Import your SupervisorPage file

void main() {
  runApp(MineBaseApp());
}

class MineBaseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mine Base Dashboard',
      theme: ThemeData(
        primaryColor: Color(0xFF3B82F6),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Color(0xFF10B981), // success green
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      home: SupervisorPage(), // Set SupervisorPage as the home screen
    );
  }
}
