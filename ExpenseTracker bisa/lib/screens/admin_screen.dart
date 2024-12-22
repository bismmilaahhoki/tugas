import 'package:flutter/material.dart';
// import 'home_screen.dart'; // Halaman utama untuk pengguna biasa
// import 'admin_screen.dart'; // Halaman untuk admin

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Fungsi login
  void _login() {
    if (_formKey.currentState!.validate()) {
      final user = _userController.text;
      final password = _passwordController.text;

      if (user == 'admin' && password == 'admin123') {
        // Login admin
        Navigator.pushReplacementNamed(context, '/admin');
      } else if (user == 'hmti' && password == 'hmti') {
        // Login pengguna biasa
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Jika login gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email atau password salah')),
        );
      }
    }
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Text('Halaman Admin'),
    ));
  }
}
