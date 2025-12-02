import 'package:flutter/material.dart';
import 'task_manager_page.dart';
import '../widgets/navbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Navbar(),
      body: const TaskManagerPage(),
    );
  }
}
