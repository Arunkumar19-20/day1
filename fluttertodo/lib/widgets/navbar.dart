import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/feature_page.dart';
import '../pages/contact_page.dart';
import '../pages/login_page.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Task Manager", style: TextStyle(color: Colors.white)),
      backgroundColor: const Color(0xFF0d1b2a),
      actions: [
        TextButton(
          onPressed: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomePage())),
          child: const Text("Home", style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const FeaturePage())),
          child: const Text("Feature", style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const ContactPage())),
          child: const Text("Contact", style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const LoginPage())),
          child: const Text("Login", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
