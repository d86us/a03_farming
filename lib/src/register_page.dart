import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:a03_farming/src/services/database_helper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String _error = '';

  Future<void> _handleRegister() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter both email and password');
      return;
    }

    try {
      final userId = await DatabaseHelper.registerUser(email, password);
      if (!mounted) return;

      if (userId > 0) {
        // Store the user's credentials securely
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        await prefs.setString('password', password);

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() => _error = 'Registration failed');
      }
    } on Exception catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                onPressed: _handleRegister,
                child: const Text('Register'),
              ),
              const SizedBox(height: 12),
              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child:
                      Text(_error, style: const TextStyle(color: Colors.red)),
                ),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                child: const Text('Already have an account? Log in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}