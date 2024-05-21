import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'userDetail.dart';

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
  
  String _selectedFcmType = 'android';

  void initState() {
    super.initState();
    _checkUserDetails();
  }

  List<String> _fcmTypes = ['android', 'ios'];

  Future<void> _checkUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? token = prefs.getString('token');
    String? username = prefs.getString('username');

    if(userId!= null && token!=null) {
      Navigator.push(context, MaterialPageRoute(builder: (context)=>
      MainPage(token: token , userId: userId)));
    }
  }
  
  Future<void> _saveDataLocally(String userId, String token ,String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId.trim());
    await prefs.setString('token', token.trim());
    await prefs.setString('username', username.trim());
  }

  Future<void> _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    _selectedFcmType = 'android';

    final response = await http.post(
      Uri.parse('http://3.110.219.27:8005/stapi/v1/login/'),
      body: {'username': username, 'password': password, 'fcm_type': _selectedFcmType},
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      String userId = data['id'].toString();
      String token = data['token'];

      _saveDataLocally(userId, token , username);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(token: token , userId: userId),
        ),
      );
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
        margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
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
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            // DropdownButtonFormField<String>(
            //   value: _selectedFcmType,
            //   onChanged: (String? value) {
            //     setState(() {
            //       _selectedFcmType = value!;
            //     });
            //   },
            //   items: _fcmTypes.map((String fcmType) {
            //     return DropdownMenuItem<String>(
            //       value: fcmType,
            //       child: Text(fcmType),
            //     );
            //   }).toList(),
            //   decoration: const InputDecoration(
            //     labelText: 'FCM Type',
            //   ),
            // ),
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
