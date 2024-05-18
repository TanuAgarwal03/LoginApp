// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'userDetail.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   String _errorMessage = '';
//   bool _passwordVisible = false;

//   Future<void> _saveDataLocally(String userId, String token) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('userId', userId.trim());
//     await prefs.setString('token', token.trim());
//   }

//   Future<void> _login() async {
//     String username = _usernameController.text.trim();
//     String password = _passwordController.text.trim();

//     final response = await http.post(
//       Uri.parse('http://192.168.1.26:8000/login_api/'),
//       body: {'username': username, 'password': password},
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       String userId = data['user']['id'].toString();
//       String token = data['user']['token'];

//       _saveDataLocally(userId, token);

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => UserDetailPage(data: data),
//         ),
//       );
//     } else {
//       setState(() {
//         _errorMessage = 'Invalid username or password.';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Login Page'),
//       ),
//       body: Container(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             if (_errorMessage.isNotEmpty)
//               Text(
//                 _errorMessage,
//                 style: const TextStyle(color: Colors.red),
//               ),
//             TextFormField(
//               controller: _usernameController,
//               decoration: const InputDecoration(
//                 labelText: 'Username',
//               ),
//             ),
//             const SizedBox(height: 20.0),
//             TextFormField(
//               controller: _passwordController,
//               obscureText: !_passwordVisible,
//               decoration: InputDecoration(
//                 labelText: 'Password',
//                 suffixIcon: IconButton(
//                   icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
//                   onPressed: () {
//                     setState(() {
//                       _passwordVisible = !_passwordVisible;
//                     });
//                   },
//                 ),
//               ),
//             ),
//             const SizedBox(height: 40.0),
//             ElevatedButton(
//               onPressed: _login,
//               child: const Text('Login'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'userDetail.dart';

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

  void initState() {
    super.initState();
    _checkUserDetails();
  }

  Future<void> _checkUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? token = prefs.getString('token');

    if(userId!= null && token!=null) {
      Navigator.push(context, MaterialPageRoute(builder: (context)=>
      UserDetailPage(token:token , userId :userId)));
    }
    
  }
  Future<void> _saveDataLocally(String userId, String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId.trim());
    await prefs.setString('token', token.trim());
  }

  Future<void> _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    final response = await http.post(
      Uri.parse('http://192.168.124.100:8000/login_api/'),
      body: {'username': username, 'password': password},
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      String userId = data['user']['id'].toString();
      String token = data['user']['token'];

      _saveDataLocally(userId, token);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserDetailPage(token:token , userId :userId),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Invalid username or password.';
      });
    }
  }

  // Future<void> _isLoggedIn() async{
  //   final bool check = await _checkUserDetails();

  // }
  // Future<bool> _checkUserDetails() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? userId = prefs.getString('userId');
  //   String? token = prefs.getString('token');
  //   return userId != null && token != null;
  // }

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
