import 'package:flutter/material.dart';
import 'mockup_screen.dart';

void main() {
  runApp(const MineApp());
}

class MineApp extends StatelessWidget {
  const MineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MockupScreen(supervisorId: "SUP-01"),
    );
  }
}
