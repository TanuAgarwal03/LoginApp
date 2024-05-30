// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:login_page/login.dart';

// class ResetPasswordPage extends StatefulWidget {
//   const ResetPasswordPage({super.key});

//   @override
//   State<ResetPasswordPage> createState() => _ResetPasswordPageState();
// }

// class _ResetPasswordPageState extends State<ResetPasswordPage> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _otpController = TextEditingController();
//   final TextEditingController _newPasswordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();
//   String _message = '';
//   bool _passwordVisible = false;
//   bool _confirmPasswordVisible = false;

//   Future<void> _resetPassword() async {
//     if (_formKey.currentState?.validate() != true) {
//       return;
//     }

//     String username = _usernameController.text.trim();
//     String otp = _otpController.text.trim();
//     String newPassword = _newPasswordController.text.trim();
//     String confirmPassword = _confirmPasswordController.text.trim();

//     final response = await http.post(
//       Uri.parse('http://3.110.219.27:8005/stapi/v1/new-password/'),
//       body: {
//         'username': username,
//         'otp': otp,
//         'password': newPassword,
//         'cpassword': confirmPassword,
//       },
//     );

//     if (response.statusCode == 201) {
//       setState(() {
//         _message = 'Password reset successfully. Please login with your new password.';
//       });
//        Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginPage()),
//       );

//       // Optionally, navigate back to the login page
//     } else {
//       setState(() {
//         _message = 'Failed to reset password. Please try again.';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(
//             color: Colors.white, // Change the arrow color to white
//           ),
//         title: const Text('Reset Password', style: TextStyle(color: Colors.white),),
//         backgroundColor: const Color.fromARGB(255, 54, 125, 206),

//       ),
//       body: Container(
//         padding: const EdgeInsets.all(30.0),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Image.asset('assets/image/resetpwd.jpg',height: 200.0, width: 200.0),
//               const SizedBox(height: 10.0),
//               const Text('Your new password must be different\n      from previously used password',style: TextStyle(color: Colors.grey), ),
//               const SizedBox(height: 15.0),

//               TextFormField(
//                 controller: _usernameController,
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Colors.white,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20.0),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20.0),
//                     borderSide: const BorderSide(color: Colors.blue),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20.0),
//                     borderSide: const BorderSide(
//                         color: Color.fromARGB(255, 90, 89, 89)),
//                   ),
//                   labelText: 'Username',
//                   hintText: 'Enter email',
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your username or mobile number';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20.0),

//               TextFormField(
//                 controller: _otpController,
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Colors.white,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20.0),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20.0),
//                     borderSide: const BorderSide(color: Colors.blue),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20.0),
//                     borderSide: const BorderSide(
//                         color: Color.fromARGB(255, 90, 89, 89)),
//                   ),
//                   labelText: 'Enter OTP',
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter the OTP';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20.0),
//               TextFormField(
//                 controller: _newPasswordController,
//                 obscureText: !_passwordVisible,
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Colors.white,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20.0),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20.0),
//                     borderSide: const BorderSide(color: Colors.blue),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20.0),
//                     borderSide: const BorderSide(
//                         color: Color.fromARGB(255, 90, 89, 89)),
//                   ),
//                   labelText: 'New password',
//                   suffixIcon: IconButton(
//                     icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
//                     onPressed: () {
//                       setState(() {
//                         _passwordVisible = !_passwordVisible;
//                       });
//                     },
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your new password';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20.0),
//               TextFormField(
//                 controller: _confirmPasswordController,
//                 obscureText: !_confirmPasswordVisible,
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Colors.white,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20.0),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20.0),
//                     borderSide: const BorderSide(color: Colors.blue),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20.0),
//                     borderSide: const BorderSide(
//                         color: Color.fromARGB(255, 90, 89, 89)),
//                   ),
//                   labelText: 'Confirm password',
//                   suffixIcon: IconButton(
//                     icon: Icon(_confirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
//                     onPressed: () {
//                       setState(() {
//                         _confirmPasswordVisible = !_confirmPasswordVisible;
//                       });
//                     },
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please confirm your new password';
//                   }
//                   if (value != _newPasswordController.text) {
//                     return 'Passwords do not match';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 30.0),
//             ElevatedButton(
//               onPressed: _resetPassword,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color.fromARGB(255, 54, 125, 206),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10.0),
//                 )
//               ),
//               child: const Text('Reset Password' , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold),)              
//             ),
//               // const SizedBox(height: 40.0),
//               // ElevatedButton(
//               //   onPressed: _resetPassword,
//               //   child: const Text('Reset Password'),
//               // ),
//               // const SizedBox(height: 20.0),
//               if (_message.isNotEmpty)
//                 Text(
//                   _message,
//                   style: const TextStyle(color: Colors.red),
//                 ),
//             ],
//           ),
//           ) 
          
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/login.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String _message = '';
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  Future<void> _resetPassword() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    String username = _usernameController.text.trim();
    String otp = _otpController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    try {
      final response = await http.post(
        Uri.parse('http://3.110.219.27:8005/stapi/v1/new-password/'),
        body: {
          'username': username,
          'otp': otp,
          'password': newPassword,
          'cpassword': confirmPassword,
        },
      );

      if (response.statusCode == 201) {
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // await prefs.setString('password', newPassword);
        setState(() {
          _message = 'Password reset successfully. Please login with your new password.';
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        final responseJson = json.decode(response.body);
        setState(() {
          _message = responseJson['message'] ?? 'Failed to reset password. Please try again.';
        });
      }
    } catch (error) {
      setState(() {
        _message = 'Failed to reset password. Please try again later.';
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
        title: const Text('Reset Password', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 54, 125, 206),
      ),
      body: Container(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/image/resetpwd.jpg', height: 200.0, width: 200.0),
                const SizedBox(height: 10.0),
                const Text('Your new password must be different\n      from previously used password', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 15.0),
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
                      borderSide: const BorderSide(color: Color.fromARGB(255, 90, 89, 89)),
                    ),
                    labelText: 'Username',
                    hintText: 'Enter email',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username or mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _otpController,
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
                      borderSide: const BorderSide(color: Color.fromARGB(255, 90, 89, 89)),
                    ),
                    labelText: 'Enter OTP',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the OTP';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: !_passwordVisible,
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
                      borderSide: const BorderSide(color: Color.fromARGB(255, 90, 89, 89)),
                    ),
                    labelText: 'New password',
                    suffixIcon: IconButton(
                      icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
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
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_confirmPasswordVisible,
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
                      borderSide: const BorderSide(color: Color.fromARGB(255, 90, 89, 89)),
                    ),
                    labelText: 'Confirm password',
                    suffixIcon: IconButton(
                      icon: Icon(_confirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _confirmPasswordVisible = !_confirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30.0),
                ElevatedButton(
                  onPressed: _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 54, 125, 206),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Reset Password',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                if (_message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      _message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
