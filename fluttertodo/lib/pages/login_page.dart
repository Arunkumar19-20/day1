import 'package:flutter/material.dart';
import '../widgets/navbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  void login() {
    if (userCtrl.text == "admin" && passCtrl.text == "1234") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Login Successful!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("❌ Invalid Credentials")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Navbar(),
      body: Container(
        color: Colors.grey.shade800,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              inputBox(userCtrl, "Username"),
              inputBox(passCtrl, "Password", isPass: true),
              ElevatedButton(onPressed: login, child: const Text("Login")),
            ],
          ),
        ),
      ),
    );
  }

  Widget inputBox(TextEditingController c, String hint, {bool isPass = false}) => Container(
    margin: const EdgeInsets.all(10),
    width: 250,
    child: TextField(
      controller: c,
      obscureText: isPass,
      decoration: InputDecoration(
        hintText: hint,
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
