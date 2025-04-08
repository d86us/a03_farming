import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:a03_farming/src/services/database_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? _error;

  Future<void> _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter both email and password');
      return;
    }

    final user = await DatabaseHelper.loginUser(email, password);
    if (!mounted) return;

    if (user != null) {
      // Store the user's credentials securely
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      await prefs.setString('password', password);

      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _error = 'Invalid email or password');
    }
  }

  Future<void> _autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');

    if (email != null && password != null) {
      final user = await DatabaseHelper.loginUser(email, password);
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _autoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_error != null) ...[
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 10),
            ],
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleLogin,
              child: const Text('Login'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/register'),
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}