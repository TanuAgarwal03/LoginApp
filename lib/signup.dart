import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/login.dart';
import 'package:login_page/otpVerify.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  String _errorMessage = '';
  String _selectedFcmType = 'android';
  // ignore: unused_field
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
      final response = await http.get(
          Uri.parse('http://3.110.219.27:8005/stapi/v1/geolocation/country/'));

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
        _isLoading = false;
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
      final response = await http.get(
          Uri.parse('http://3.110.219.27:8005/stapi/v1/geolocation/state/'));

      if (response.statusCode == 200) {
        final parsedResponse = jsonDecode(response.body);
        List<dynamic> states = parsedResponse['results'];

        setState(() {
          _states = states
              .where((state) => state['country'] == countryId)
              .map<Map<String, dynamic>>((state) {
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
            builder: (context) =>
                OtpVerificationPage(email: _emailController.text.trim())),
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
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   title: const Text(''),
        // ),
        body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/image/login.png'),
                  fit: BoxFit.fill),
            ),
            padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 30.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FloatingActionButton.small(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          100.0), // Ensures the button is circular
                                    ),
                    backgroundColor: Colors.white,
                    child:  const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(height: 30.0,),
                  const Text('Create \nAccount',
                      style: TextStyle(color: Colors.white, fontSize: 40)),
                  const SizedBox(height: 70.0),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (_errorMessage.isNotEmpty)
                            Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ListTile(
                            title: TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(255, 228, 226, 226),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide:
                                      const BorderSide(color: Colors.blue),
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
                          ListTile(
                            title: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(255, 228, 226, 226),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide:
                                      const BorderSide(color: Colors.blue),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 90, 89, 89)),
                                ),
                                labelText: 'Email',
                                hintText: 'Enter email address',
                              ),
                            ),
                          ),
                          ListTile(
                            title: TextFormField(
                              controller: _firstNameController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(255, 228, 226, 226),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide:
                                      const BorderSide(color: Colors.blue),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 90, 89, 89)),
                                ),
                                labelText: 'First name',
                                hintText: 'Enter first name',
                              ),
                            ),
                          ),
                          ListTile(
                            title: TextFormField(
                              controller: _lastNameController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(255, 228, 226, 226),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide:
                                      const BorderSide(color: Colors.blue),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 90, 89, 89)),
                                ),
                                labelText: 'Last name',
                                hintText: 'Enter last name',
                              ),
                            ),
                          ),
                          ListTile(
                            title: TextFormField(
                              controller: _mobileController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(255, 228, 226, 226),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide:
                                      const BorderSide(color: Colors.blue),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 90, 89, 89)),
                                ),
                                labelText: 'Mobile no.',
                                hintText: 'Enter mobile no.',
                              ),
                            ),
                          ),
                          ListTile(
                            title: TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(255, 228, 226, 226),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide:
                                      const BorderSide(color: Colors.blue),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 90, 89, 89)),
                                ),
                                labelText: 'Password',
                                hintText: 'Enter password',
                              ),
                              obscureText: true,
                            ),
                          ),
                          ListTile(
                            title: TextFormField(
                              controller: _confirmPasswordController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(255, 228, 226, 226),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide:
                                      const BorderSide(color: Colors.blue),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 90, 89, 89)),
                                ),
                                labelText: 'Confirm Password',
                                hintText: 'confirm password',
                              ),
                            ),
                          ),
                          ListTile(
                            title: DropdownButtonFormField<int>(
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
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(255, 228, 226, 226),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide:
                                      const BorderSide(color: Colors.blue),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 90, 89, 89)),
                                ),
                              ),
                              items: _countries
                                  .map<DropdownMenuItem<int>>((country) {
                                return DropdownMenuItem<int>(
                                  key: Key(country['name']),
                                  value: country['id'],
                                  child: Text(country['name']),
                                );
                              }).toList(),
                            ),
                          ),
                          ListTile(
                            title: DropdownButtonFormField<int>(
                              hint: const Text('Select State'),
                              value: _selectedState,
                              onChanged: (int? value) {
                                setState(() {
                                  _selectedState = value;
                                });
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(255, 228, 226, 226),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide:
                                      const BorderSide(color: Colors.blue),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 90, 89, 89)),
                                ),
                              ),
                              items:
                                  _states.map<DropdownMenuItem<int>>((state) {
                                return DropdownMenuItem<int>(
                                  key: Key(state['name']),
                                  value: state['id'],
                                  child: Text(state['name']),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 40.0),
                          Center(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(50.0, 0.0, 10.0, 0.0),
                                  child: InkWell(
                                      child: Text('Sign Up',
                                          style: TextStyle(
                                            fontSize: 30,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ))),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      20.0, 0.0, 35.0, 0.0),
                                  child: FloatingActionButton.small(
                                    onPressed: () {
                                      _signUp();
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          100.0), // Ensures the button is circular
                                    ),
                                    backgroundColor:
                                        Color.fromARGB(255, 114, 112, 112),
                                    child:
                                        const Icon(Icons.arrow_forward_rounded),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30.0),
                          Center(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(30.0),
                                  child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const LoginPage()),
                                        );
                                      },
                                      child: const Text(
                                          'Already have an account ? Sign In',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              decoration:
                                                  TextDecoration.underline))),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ])));
  }
}
