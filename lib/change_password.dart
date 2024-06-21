// import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:login_page/apiService.dart';
// import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_page/login.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  String _message = '';
  bool _oldPasswordVisible = false;
  bool _newPasswordVisible = false;
  ApiService apiService = ApiService();


  Future<String?> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _changePassword(String token) async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    String oldPassword = _oldPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();

    final response = await apiService.postAPI('change-password/', {
        'old_password': oldPassword,
        'new_password': newPassword,
      },headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token', 
      },);
    // final response = await http.post(
    //   Uri.parse('https://test.securitytroops.in/stapi/v1/change-password/'),
    //   headers: {
    //     'Content-Type': 'application/json',
    //     'Authorization': 'Token $token', 
    //   },
    //   body: jsonEncode({
    //     'old_password': oldPassword,
    //     'new_password': newPassword,
    //   }),
    // );

    final responseBody = response.body;
    print('Response status: ${response.statusCode}');
    print('Response body: $responseBody');

    if (response.statusCode == 201) {
      setState(() {
        _message = 'Password changed successfully. Please login with your new password.';
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      setState(() {
        _message = 'Failed to change password. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/image/forgetpwd.jpg',height: 150.0, width: 150.0),
              const SizedBox(height: 20),
              TextFormField(
                controller: _oldPasswordController,
                obscureText: !_oldPasswordVisible,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 90, 89, 89)),
                  ),
                  labelText: 'Old Password',
                  suffixIcon: IconButton(
                    icon: Icon(_oldPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _oldPasswordVisible = !_oldPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your old password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_newPasswordVisible,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 90, 89, 89)),
                  ),
                  labelText: 'New Password',
                  suffixIcon: IconButton(
                    icon: Icon(_newPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _newPasswordVisible = !_newPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your new password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40.0),
              ElevatedButton(
                onPressed: () async {
                  String? token = await _getAuthToken();
                  if (token != null) {
                    _changePassword(token);
                  } else {
                    setState(() {
                      _message = 'Authentication error. Please login again.';
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  )
                ),
                child: const Text('Change Password' , style: TextStyle(color: Colors.white , fontSize: 16),),
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
      ),
    );
  }
}
