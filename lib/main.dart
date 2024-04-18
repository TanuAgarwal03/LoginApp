import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:login_page/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController =
      TextEditingController(); //TextEditingController objects for handling the text input
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage =
      ''; //a string _errorMessage to display validation errors.

Future<void> _login() async {
  String username = _usernameController.text.trim();
  String password = _passwordController.text.trim();

  // Send POST request to Django API endpoint
  final response = await http.post(
    Uri.parse('http://192.168.1.17:8000/login_api/'),
    body: {'username': username, 'password': password},
  );

  // Handle response
  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    print(data);
    // Authentication successful
    // Navigate to the UserDetailPage and pass the data received from the API
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailPage(data: data),
      ),
    );
  } else {
    // Authentication failed
    setState(() {
      _errorMessage = 'Invalid username or password.';
    });
  }
}

  
//   void _login() {
//     String username = _usernameController.text.trim();
//     String password = _passwordController.text.trim();

//The build method builds the UI of the login page. It returns a Scaffold widget with an AppBar containing the title 'Login Page' and a body containing the main content.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 40.0),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class UserDetailPage extends StatelessWidget {
  final dynamic data;

  const UserDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Split the data by commas
    List<String> details = data.toString().split(',');

    _saveDataLocally(details[11]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display each detail on a new line
            for (var detail in details)
              Text(detail.trim(), style: const TextStyle(fontSize: 18)),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Navigate back to the login page
              },
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _saveDataLocally(String userId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  // Save the user ID to shared preferences
  await prefs.setString('userId', userId.trim());
  print("User ID saved to local storage");
  print(userId);
  }

}