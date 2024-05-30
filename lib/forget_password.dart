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
        iconTheme: const IconThemeData(
            color: Colors.white, // Change the arrow color to white
          ),
        title: const Text('Forget Password', style: TextStyle(color: Colors.white),),
        backgroundColor: const Color.fromARGB(255, 54, 125, 206),
      ),
      body: Container(
        padding: const EdgeInsets.all(60.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/image/forgetpwd.jpg',height: 280.0, width: 300.0),
            const SizedBox(height: 5.0),
            const Text('Please enter your Email address \n       to reset your password.' , style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),

            const SizedBox(height: 28.0),

            TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 90, 89, 89)),
                  ),
                  labelText: 'Enter your Email address',
                  hintText: 'email address',
                ),
              ),
            const SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: _forgotPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 54, 125, 206),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                )
              ),
              child: const Text('Proceed' , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold),)              
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
