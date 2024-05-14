// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class UpdateUserPage extends StatefulWidget {
//   final String userId;
//   final String token;

//   const UpdateUserPage({super.key, required this.userId, required this.token});

//   @override
//   State<UpdateUserPage> createState() => _UpdateUserPageState();
// }

// class _UpdateUserPageState extends State<UpdateUserPage> {
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();
//   final TextEditingController _countryController = TextEditingController();
//   final TextEditingController _stateController = TextEditingController();
//   final TextEditingController _dobController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserDetails();
//   }

//   Future<void> _fetchUserDetails() async {
//     final response = await http.get(
//       Uri.parse('http://192.168.1.26:8000/user/${widget.userId}/'),
//       headers: {
//         'Authorization': 'token ${widget.token}',
//         'Content-Type': 'application/json',
//       },
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);

//       setState(() {
//         _usernameController.text = data['username'] ?? '';
//         _emailController.text = data['email'] ?? '';
//         _firstNameController.text = data['first_name'] ?? '';
//         _lastNameController.text = data['last_name'] ?? '';
//         _countryController.text = data['country'] ?? '';
//         _stateController.text = data['state'] ?? '';
//         _dobController.text = data['dob'] ?? '';
//       });
//     } else {
//       print('Failed to fetch user details. Status code: ${response.statusCode}');
//     }
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null && picked != DateTime.now()) {
//       setState(() {
//         _dobController.text = "${picked.toLocal()}".split(' ')[0]; // Format the date
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Update User Details'),
//       ),
//       body: Container(
//         margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.3),
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             TextFormField(
//               controller: _usernameController,
//               decoration: const InputDecoration(labelText: 'Username'),
//             ),
//             TextFormField(
//               controller: _emailController,
//               decoration: const InputDecoration(labelText: 'Email'),
//             ),
//             TextFormField(
//               controller: _firstNameController,
//               decoration: const InputDecoration(labelText: 'First Name'),
//             ),
//             TextFormField(
//               controller: _lastNameController,
//               decoration: const InputDecoration(labelText: 'Last Name'),
//             ),
//             TextFormField(
//               controller: _countryController,
//               decoration: const InputDecoration(labelText: 'Country'),
//             ),
//             TextFormField(
//               controller: _stateController,
//               decoration: const InputDecoration(labelText: 'State'),
//             ),
//             TextFormField(
//               controller: _dobController,
//               readOnly: true,
//               onTap: () => _selectDate(context), // Trigger date picker on tap
//               decoration: const InputDecoration(labelText: 'Date of Birth'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 // Retrieve the values entered by the user
//                 String username = _usernameController.text.trim();
//                 String email = _emailController.text.trim();
//                 String firstName = _firstNameController.text.trim();
//                 String lastName = _lastNameController.text.trim();
//                 String country = _countryController.text.trim();
//                 String state = _stateController.text.trim();
//                 String dob = _dobController.text.trim();

//                 // Construct the JSON payload
//                 Map<String, dynamic> data = {
//                   'username': username,
//                   'email': email,
//                   'first_name': firstName,
//                   'last_name': lastName,
//                   'country': country,
//                   'state': state,
//                   'dob': dob,
//                 };

//                 // Send PUT request to update user details
//                 try {
//                   final response = await http.put(
//                     Uri.parse('http://192.168.1.26:8000/user/${widget.userId}/'),
//                     headers: {
//                       'Content-Type': 'application/json',
//                       'Authorization': 'token ${widget.token}',
//                     },
//                     body: jsonEncode(data),
//                   );

//                   if (response.statusCode == 200) {
//                     Navigator.pop(context, data); // sending the updated data to userDetailPage
//                     print("Details updated");
//                   } else {
//                     print('Failed to update user details. Status code: ${response.statusCode}');
//                   }
//                 } catch (e) {
//                   print('Error updating user details: $e');
//                 }
//               },
//               child: const Text('Update'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class UserDetailItem extends StatelessWidget {
//   final String label;
//   final String value;

//   const UserDetailItem({super.key, required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '$label: ',
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontSize: 18),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UpdateUserPage extends StatefulWidget {
  final String userId;
  final String token;

  const UpdateUserPage({super.key, required this.userId, required this.token});

  @override
  State<UpdateUserPage> createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    setState(() {

      _isLoading = true;
    
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.26:8000/user/${widget.userId}/'),
        headers: {
          'Authorization': 'token ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _usernameController.text = data['username'] ?? '';
          _emailController.text = data['email'] ?? '';
          _firstNameController.text = data['first_name'] ?? '';
          _lastNameController.text = data['last_name'] ?? '';
          _countryController.text = data['country'] ?? '';
          _stateController.text = data['state'] ?? '';
          _dobController.text = data['dob'] ?? '';

          _isLoading = false;
        });
      } else {
        print('Failed to fetch user details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user details: $e');      
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dobController.text = "${picked.toLocal()}".split(' ')[0]; // Format the date
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update User Details'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Display loader
          : Container(
              margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.3),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                  ),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                  ),
                  TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(labelText: 'Country'),
                  ),
                  TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(labelText: 'State'),
                  ),
                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    onTap: () => _selectDate(context), // Trigger date picker on tap
                    decoration: const InputDecoration(labelText: 'Date of Birth'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // Retrieve the values entered by the user
                      String username = _usernameController.text.trim();
                      String email = _emailController.text.trim();
                      String firstName = _firstNameController.text.trim();
                      String lastName = _lastNameController.text.trim();
                      String country = _countryController.text.trim();
                      String state = _stateController.text.trim();
                      String dob = _dobController.text.trim();

                      // Construct the JSON payload
                      Map<String, dynamic> data = {
                        'username': username,
                        'email': email,
                        'first_name': firstName,
                        'last_name': lastName,
                        'country': country,
                        'state': state,
                        'dob': dob,
                      };

                      // Send PUT request to update user details
                      try {
                        final response = await http.put(
                          Uri.parse('http://192.168.1.26:8000/user/${widget.userId}/'),
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': 'token ${widget.token}',
                          },
                          body: jsonEncode(data),
                        );

                        if (response.statusCode == 200) {
                          Navigator.pop(context, data); // sending the updated data to userDetailPage
                          print("Details updated");
                        } else {
                          print('Failed to update user details. Status code: ${response.statusCode}');
                        }
                      } catch (e) {
                        print('Error updating user details: $e');
                      }
                    },
                    child: const Text('Update'),
                  ),
                ],
              ),
            ),
    );
  }
}

