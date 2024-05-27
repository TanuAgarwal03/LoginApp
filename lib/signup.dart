import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/login.dart';
import 'package:login_page/otpVerify.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  String _errorMessage = '';
  String _selectedFcmType = 'android';
  bool _isLoading = false;

  List<Map<String, dynamic>> _states = [];
  int? _selectedCountry;
  int? _selectedState;
  List<Map<String, dynamic>> _countries = [];

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  Future<void> _fetchCountries() async {
    try {
      _isLoading = true;
      final response = await http.get(Uri.parse('http://3.110.219.27:8005/stapi/v1/geolocation/country/'));

      if (response.statusCode == 200) {
        final parsedResponse = jsonDecode(response.body);
        List<dynamic> countries = parsedResponse['results'];

        setState(() {
          _countries = countries.map<Map<String, dynamic>>((country) {
            return {
              'id': country['id'],
              'name': country['name'],
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        _isLoading  = false;
        throw Exception('Failed to load countries');
      }
    } catch (e) {
      print('Error loading countries: $e');
      setState(() {
        _errorMessage = 'Failed to load countries';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchStates(int countryId) async {
    try {
      final response = await http.get(Uri.parse('http://3.110.219.27:8005/stapi/v1/geolocation/state/'));

      if (response.statusCode == 200) {
        final parsedResponse = jsonDecode(response.body);
        List<dynamic> states = parsedResponse['results'];

        setState(() {
          _states = states.where((state) => state['country'] == countryId).map<Map<String, dynamic>>((state) {
            return {
              'id': state['id'],
              'name': state['name'],
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load states');
      }
    } catch (e) {
      print('Error loading states: $e');
      setState(() {
        _errorMessage = 'Failed to load states';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signUp() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? token = prefs.getString('token');

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
        _isLoading = false;
      });
      return;
    }

    final response = await http.post(
      Uri.parse('http://3.110.219.27:8005/stapi/v1/signup/'),
      body: {
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
        'cpassword': _confirmPasswordController.text.trim(),
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'fcm_type': _selectedFcmType,
        'country': _selectedCountry.toString(),
        'state': _selectedState?.toString(), 
        'locate': '',        
      },
    );

    if (response.statusCode == 201) {
      print('Sign up successful');
      _isLoading = false;

      final responseData = jsonDecode(response.body);
      final token = responseData['token'];

      // Save the token to local storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationPage(email: _emailController.text.trim())
          ),
      );
    } else {
      print('Sign up failed');
      setState(() {
        _errorMessage = 'Sign up failed. Please try again later.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
              ),
              const SizedBox(height: 15.0),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 15.0),
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First name',
                ),
              ),
              const SizedBox(height: 15.0),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last name',
                ),
              ),
              const SizedBox(height: 15.0),
              TextField(
                controller: _mobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile No.',
                ),
              ),
              const SizedBox(height: 15.0),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 15.0),
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 15.0),

              DropdownButtonFormField<int>(
                hint: const Text('Select country'),
                value: _selectedCountry,
                onChanged: (int? value) {
                  setState(() {
                    _selectedCountry = value;
                    _selectedState = null;
                    _states = [];
                  });
                  if (value != null) {
                    _fetchStates(value);
                  }
                },
                items: _countries.map<DropdownMenuItem<int>>((country) {
                  return DropdownMenuItem<int>(
                    key: Key(country['name']),
                    value: country['id'],
                    child: Text(country['name']),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                hint: const Text('Select State'),
                value: _selectedState,
                onChanged: (int? value) {
                  setState(() {
                    _selectedState = value;
                  });
                },
                items: _states.map<DropdownMenuItem<int>>((state) {
                  return DropdownMenuItem<int>(
                    key: Key(state['name']),
                    value: state['id'],
                    child: Text(state['name']),
                  );
                }).toList(),
              ),

              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 15.0),
              Center(
                child: ElevatedButton(
                  onPressed: _signUp,
                  child: const Text('Sign Up'),
                ),
              ),
              const SizedBox(height: 20.0),
              Center(
                child:TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text('Already have an account ? LOGIN'),
            ),
              )
              
            ],
          ),
        ),
      ),
    );
  }
}
