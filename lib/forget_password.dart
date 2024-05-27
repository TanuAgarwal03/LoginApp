// import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/reset_password.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final TextEditingController _usernameController = TextEditingController();
  String _message = '';

  Future<void> _forgotPassword() async {
    String username = _usernameController.text.trim();

    final response = await http.post(
      Uri.parse('http://3.110.219.27:8005/stapi/v1/forgot-password/'),
      body: {'username': username},
    );

    if (response.statusCode == 201) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
      );

      setState(() {
        _message = 'Set new password';
      });
    } else {
      setState(() {
        _message = 'Invalid username. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forget Password'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Email/Mobile No',
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _forgotPassword,
              child: const Text('Next'),
            ),
            const SizedBox(height: 20.0),
            if (_message.isNotEmpty)
              Text(
                _message,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
