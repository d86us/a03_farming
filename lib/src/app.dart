import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'package:a03_farming/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarmingApp extends StatefulWidget {
  const FarmingApp({super.key});

  @override
  State<FarmingApp> createState() => _FarmingAppState();
}

class _FarmingAppState extends State<FarmingApp> {
  late Future<String> _initialRouteFuture;

  @override
  void initState() {
    super.initState();
    _initialRouteFuture = _checkLoginStatus();
  }

  Future<String> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    return email != null ? '/home' : '/login';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialRouteFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MaterialApp(
            title: 'Farming Tips',
            debugShowCheckedModeBanner: false,
            initialRoute: snapshot.data, // Start with login or home
            routes: {
              '/login': (context) => const LoginPage(),
              '/register': (context) => const RegisterPage(),
              '/home': (context) => const HomePage(),
            },
          );
        } else {
          return Container(
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(FarmingApp());
}