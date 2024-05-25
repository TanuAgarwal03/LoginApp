import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  // List<String> _countries = [];
  // State and Country variables
//   List<String> _countries = [];
//   List<String> _countryIds = [];
//   List<String> _states = [];
//   List<String> _stateIds = [];
// List<String> _stateCountryIds = [];

  // int? _selectedCountry;
  // String _selectedState = '';

  int? _selectedCountry;
  List<Map<String, dynamic>> _countries = [];
// String? _errorMessage;
// bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }
//   Future<void> _fetchCountries() async {
//   try {
//     final response = await http.get(Uri.parse('http://3.110.219.27:8005/stapi/v1/geolocation/country/'));

//     if (response.statusCode == 200) {
//       final parsedResponse = jsonDecode(response.body);
//       List<dynamic> countries = parsedResponse['results'];

//       setState(() {
//         _countries = countries.map<String>((country) => country['name'].toString()).toList();
//         // Optionally, you can store country IDs as well for later use
//         // _countryIds = countries.map<String>((country) => country['id'].toString()).toList();
//       });
//     } else {
//       throw Exception('Failed to load countries');
//     }
//   } catch (e) {
//     print('Error loading countries: $e');
//     setState(() {
//       _errorMessage = 'Failed to load countries';
//     });
//   } finally {
//     setState(() {
//       _isLoading = false; // Make sure to set loading state to false
//     });
//   }
// }
Future<void> _fetchCountries() async {
  try {
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
      });
    } else {
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
  // Future<void> _fetchCountries() async {
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   final response = await http.post(Uri.parse('http://3.110.219.27:8005/stapi/v1/geolocation/country/'),
  //     // body: json.encode({
  //     //   'id': countryId,
  //     //   'name' : countryName,
  //     // }),
  //   );

  //     if (response.statusCode == 200) {
  //       final parsedResponse = jsonDecode(response.body);
  //       List<dynamic> countries = parsedResponse['results'];

  //       setState(() {
  //         _countries = countries.map((country) => country['name'].toString()).toList();
  //       });
  //     } else {
  //       throw Exception('Failed to load countries');
  //     }

    // if (response.statusCode == 200) {
    //   setState(() {
    //     countryId = jsonDecode(response.body)['results']['id'];
    //     countryName = jsonDecode(response.body)['results']['name'];
    //     _isLoading = false;
    //   });
    // } else {
    //   setState(() {
    //     _isLoading = false;
    //   });
    //   throw Exception('Failed to submit answer');
    // }
  // }
  // Future<void> _fetchCountries() async {
  //   try {
  //     final response = await http.get(Uri.parse('http://3.110.219.27:8005/stapi/v1/geolocation/country/'));
  //     if (response.statusCode == 200) {
  //     final parsedResponse = jsonDecode(response.body);
  //     List<dynamic> countries = parsedResponse['results'];

  //     setState(() {
  //       _countries = countries.map((country) => country['name'].toString()).toList();
  //       _countryIds = countries.map((country) => country['id'].toString()).toList();
  //     });
  //     } else {
  //       throw Exception('Failed to load countries');
  //     }  
  //   } catch (e) {
  //     print('Error loading countries: $e');
  //     setState(() {
  //       _errorMessage = 'Failed to load countries';
  //     });
  //   }
  // }

//   Future<void> _fetchStates(String countryId) async {
//   try {
//     final response = await http.get(Uri.parse('http://3.110.219.27:8005/stapi/v1/geolocation/state/?country=$countryId'));

//     if (response.statusCode == 200) {
//       final parsedResponse = jsonDecode(response.body);
//       List<dynamic> states = parsedResponse['results'];

//       setState(() {
//         // _states = states.map((state) => state['name'].toString()).toList();
//         // _stateIds = states.map((state) => state['id'].toString()).toList();
//         // _stateCountryIds = states.map((state) => state['countries']['id'].toString()).toList();
//       });
//     } else {
//       throw Exception('Failed to load states');
//     }
//   } catch (e) {
//     print('Error loading states: $e');
//     setState(() {
//       _errorMessage = 'Failed to load states';
//     });
//   }
// }



  Future<void> _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    final response = await http.post(Uri.parse('http://3.110.219.27:8005/stapi/v1/signup/'),
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
          // 'state': _selectedState,
        });

    if (response.statusCode == 200) {
      print('Sign up successful');
    } else {
      print('Sign up failed');
      setState(() {
        _errorMessage = 'Sign up failed. Please try again later.';
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
                hint: Text('Select country'),
                value: _selectedCountry,
                onChanged: (int? value) {
                  setState(() {
                    _selectedCountry = value;
                  });
                },
                items: _countries.map<DropdownMenuItem<int>>((country) {
                  return DropdownMenuItem<int>(
                    key: Key(country['name']),
                    value: country['id'],
                    child: Text(country['name']),
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
            
            ],
          ),
        ),
      ),
    );
  }
}
