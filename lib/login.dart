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
  String companyName = '';

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
        await prefs.setString(key, value);
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
      Uri.parse('https://test.securitytroops.in/stapi/v1/login/'),
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
      // fetchCompanyData();
      _saveDataLocally(data);
      
      await _saveDataLocally({
        'userId': userId,
        'token': token,
        'username': username,
      });

      await fetchCompanyData();
      
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
  Future<void> fetchCompanyData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    if (token == null) {
    setState(() {
      print('Token not found. Please log in again.');
    });
    return;
  }

    try {
      final response = await http.get(Uri.parse('https://test.securitytroops.in/stapi/v1/agency/company/'),
      headers: {
        'Authorization' : 'Token $token',
      });
      if (response.statusCode == 200) {
        final companyData = json.decode(response.body)['results'][0];
        String companyId = companyData['id'].toString();
        String companyName = companyData['name'];

        if (companyData != null && companyData.isNotEmpty) {
          await _saveDataLocally({
            'companyname' : companyName,
            'companyId' : companyId,
          });
        }
      } else {
        throw Exception('Failed to load company data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(30.0),
        width: MediaQuery.of(context).size.width*1,
        height: MediaQuery.of(context).size.height*1,

        decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/image/login.png'),fit: BoxFit.fill),
              ),
        child: SingleChildScrollView(
          child: Column(
          
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40.0),
            const Text('Welcome \nBack !' , style: TextStyle(color: Colors.white, fontSize: 40 )),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 150.0),
            ListTile(
              title: TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 228, 226, 226),
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
                  labelText: 'Username',
                  hintText: 'Enter username',
                ),
              ),
            ),

            const SizedBox(height: 10.0),
            ListTile(
              title: TextFormField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 228, 226, 226),
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
                  labelText: 'Password',
                  hintText: 'Enter valid password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40.0),
            Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(50.0, 0.0, 10.0, 0.0),
                    child: InkWell(
                        child: Text('Sign In',
                            style: TextStyle(
                                fontSize: 30,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,))),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0.0, 35.0, 0.0),
                    child: FloatingActionButton.small(
                      onPressed: () {
                        _login();
                        // fetchCompanyData();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            100.0), // Ensures the button is circular
                      ),
                      backgroundColor: const Color.fromARGB(255, 114, 112, 112),
                      child: const Icon(Icons.arrow_forward_rounded),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),

            Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpPage()),
                          );
                        },
                        child: const Text('Sign Up',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                decoration: TextDecoration.underline))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ForgetPasswordPage()),
                          );
                        },
                        child: const Text('Forget Password?',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                decoration: TextDecoration.underline))),
                  )
                ],
              ),
            ),
          ],
        ),
        )
      ),
    );
  }
}
