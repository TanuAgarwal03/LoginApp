import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _saveDataLocally(String userId, String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId.trim());
    await prefs.setString('token', token.trim());
  }

  Future<void> _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    final response = await http.post(
      Uri.parse('http://192.168.1.26:8000/login_api/'),
      body: {'username': username, 'password': password},
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      String userId = data['user']['id'].toString();
      String token = data['user']['token'];

      _saveDataLocally(userId, token);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserDetailPage(data: data),
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
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Padding(
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
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
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


class UserDetailPage extends StatefulWidget {
  final dynamic data;
  const UserDetailPage({super.key, required this.data});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  late String userID = '';
  late String token = '';

  @override
  void initState() {
    super.initState();
    _getUserID();
    
  }

  Future<void> _getUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = prefs.getString('userId') ?? '';
    setState(() {});

    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('userId') ?? '';
    String token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('http://192.168.1.26:8000/user/$userID/'),
      headers: {'Authorization': 'token $token'},
    );

    if (response.statusCode == 200) {
      final userDetails = jsonDecode(response.body);
      setState(() {
        print("SUCCESS");
      });
    } else {
      setState(() {
        print("API ERROR");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: UserDetailItem(
                label: 'Username',
                value: widget.data['user']['username'],
              ),
            ),
            Center(
              child: UserDetailItem(
                label: 'Email',
                value: widget.data['user']['email'],
              ),
            ),
            Center(
              child: UserDetailItem(
                label: 'First Name',
                value: widget.data['user']['first_name'],
              ),
            ),
            Center(
              child: UserDetailItem(
                label: 'Last Name',
                value: widget.data['user']['last_name'],
              ),
            ),
            Center(
              child: UserDetailItem(
                label: 'Country',
                value: widget.data['user']['country'],
              ),
            ),
            Center(
              child: UserDetailItem(
                label: 'State',
                value: widget.data['user']['state'],
              ),
            ),
            Center(
              child: UserDetailItem(
                label: 'Profile image',
                value: widget.data['user']['image'],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateUserPage(
                      userId: userID,
                      token: token,
                    ),
                  ),
                );
              },
              child: const Text('Update User Details'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}


class UpdateUserProfilePage extends StatefulWidget {
  final String userId;

  UpdateUserProfilePage({required this.userId});

  @override
  _UpdateUserProfilePageState createState() => _UpdateUserProfilePageState();
}

class _UpdateUserProfilePageState extends State<UpdateUserProfilePage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  Future<void> _updateUserProfile() async {
    final url = 'http://192.168.1.26:8000/user/${widget.userId}/';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final response = await http.put(
      Uri.parse(url),
      body: json.encode({
        'userId': widget.userId,
        'name': _nameController.text,
        'email': _emailController.text,
      }),
      headers: {'Content-Type': 'application/json',
      'Authorization': 'token $token',
      },
    );
    if (response.statusCode == 200) {
      print("Updated");
    } else {
      print("changes not done");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _updateUserProfile,
              child: Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}


class UpdateUserPage extends StatefulWidget {
  final String userId;
  final String token;

  const UpdateUserPage({Key? key, required this.userId, required this.token}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update User Details'),
      ),
      body: Padding(
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
            ElevatedButton(
              onPressed: () async {
                // Retrieve the values entered by the user
                String username = _usernameController.text.trim();
                String email = _emailController.text.trim();
                String firstName = _firstNameController.text.trim();
                String lastName = _lastNameController.text.trim();
                String country = _countryController.text.trim();
                String state = _stateController.text.trim();
                
                // Construct the JSON payload
                Map<String, dynamic> data = {
                  'username': username,
                  'email': email,
                  'first_name': firstName,
                  'last_name': lastName,
                  'country': country,
                  'state': state,
                };

                // Send PUT request to update user details
                try {
                  final response = await http.put(
                    Uri.parse('http://192.168.1.26:8000/user/${widget.userId}/'),
                    headers: {
                      'Authorization': 'token ${widget.token}',
                      'Content-Type': 'application/json',
                    },
                    body: jsonEncode(data),
                  );

                  if (response.statusCode == 200) {
                    // If update successful, navigate back to UserDetailPage
                    Navigator.pop(context); // Remove UpdateUserPage from the stack
                  } else {
                    // Handle error
                    print('Failed to update user details. Status code: ${response.statusCode}');
                  }
                } catch (e) {
                  // Handle error
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


class UserDetailItem extends StatelessWidget {
  final String label;
  final String value;
  const UserDetailItem({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
