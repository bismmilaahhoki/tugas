import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import untuk SystemChrome
import 'package:praktikum_mobile/screens/seting_screen.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/edit_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // For FFI SQLite
// import 'screens/settings_screen.dart'; // Jika ada halaman pengaturan

// Future<void> logout(BuildContext context) async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.clear(); // Clear all saved data
//   Navigator.pushReplacementNamed(context, '/login'); // Navigate to login screen
// }

void main() {
  // Inisialisasi sqflite_common_ffi
  sqfliteFfiInit();

  // Atur databaseFactory ke databaseFactoryFfi
  // databaseFactory = databaseFactoryFfi;
  runApp(ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mengatur agar aplikasi berjalan dalam mode full screen
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.leanBack); // Menghilangkan status bar dan navigation bar

    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Halaman pertama yang dibuka
      initialRoute:
          '/login', // Ubah sesuai dengan halaman utama yang diinginkan
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/admin': (context) => AdminScreen(),
        '/edit': (context) => ExpenseFormScreen(),
        '/settings': (context) => SettingsScreen(), // Halaman pengaturan
      },
      // // Rute dinamis untuk halaman edit
      onGenerateRoute: (settings) {
        if (settings.name == '/edit') {
          // final expense = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => ExpenseFormScreen(),
          );
        }
        return null;
      },
    );
  }
}
