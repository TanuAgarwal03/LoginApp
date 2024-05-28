import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/forget_password.dart';
import 'package:login_page/main.dart';
import 'package:login_page/otpVerify.dart';
import 'package:login_page/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _checkUserDetails();
  }

  String _selectedFcmType = 'android';

  Future<void> _checkUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? token = prefs.getString('token');

    if (userId != null && token != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MainPage(token: token, userId: userId)),
      );
    }
  }

  Future<void> _saveDataLocally(Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Future> futures = [];
    data.forEach((key, value) async {
      if (value is String) {
        await prefs.setString(key, value.trim());
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is List<String>) {
        await prefs.setStringList(key, value);
      }
    });
    await Future.wait(futures);
  }

  Future<void> _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    _selectedFcmType = 'android';

    final response = await http.post(
      Uri.parse('http://3.110.219.27:8005/stapi/v1/login/'),
      body: {
        'username': username,
        'password': password,
        'fcm_type': _selectedFcmType
      },
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      String userId = data['id'].toString();
      String token = data['token'];
      _saveDataLocally(data);

      await _saveDataLocally({
        'userId': userId,
        'token': token,
        'username': username,
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(token: token, userId: userId),
        ),
      );
    } else if (response.statusCode == 400) {
      final data = jsonDecode(response.body);
      String token = data['token'];

      if (token != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationPage(email: username),
          ),
        );
      } else {
        setState(() {
          _errorMessage =
              'Failed to check account status. Please try again later.';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Invalid username or password.';
      });
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
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
          const Center(
          child: CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/image/ic1_launcher.png'),
          ),
          ),
          
          const SizedBox(height: 20.0),
          
          ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Username',
                hintText: 'Enter username'
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.lock),
            ),
            title: TextFormField(
              controller: _passwordController,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Password',
                hintText: 'Enter valid password',
                suffixIcon: IconButton(
                  icon: Icon(_passwordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ForgetPasswordPage()),
                  );
                },
                child: const Text(
                  'Forget password ?',
                  style: TextStyle(fontSize: 14, color: Colors.blue),
                ),
              ),
            ),
          ),

          
          const SizedBox(height: 20.0),
          FilledButton(
            onPressed: _login,
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.blue)),
            child: const Text('Login'),
          ),
          
          const SizedBox(height: 10.0),
          Center(child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Create a new account.', textAlign: TextAlign.center),
                Padding( 
                  padding: const EdgeInsets.only(left:1.0), 
                  child: InkWell( 
                    onTap: (){ 
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpPage()),
                      ); 
                    }, 
                      child: const Text('Sign Up.', style: TextStyle(fontSize: 14, color: Colors.blue))), 
                ) 
              ],
            ),
          ) ,
        ],
      ),
    ),
  );
}
}