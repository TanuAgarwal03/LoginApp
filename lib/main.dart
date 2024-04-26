import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController _usernameController =
      TextEditingController(); //TextEditingController objects for handling the text input
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = ''; //a string _errorMessage to display validation errors.


Future<void> _saveDataLocally(String userId, String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('userId', userId.trim());
  await prefs.setString('token', token.trim());
  }

Future<void> _login() async {
  String username = _usernameController.text.trim();
  String password = _passwordController.text.trim();

  // Send POST request to Django API endpoint
  final response = await http.post(
    Uri.parse('http://192.168.1.17:8000/login_api/'),
    body: {'username': username, 'password': password},
  );

  if (response.statusCode == 201) {
    final data = jsonDecode(response.body); //authentication successful
    print(data);
    String userId = data['user']['id'].toString(); // Assuming 'userId' is the key for user ID in the API response
    String token = data['user']['token'];
    
    _saveDataLocally(userId, token);
    print(userId);
    print(token);
    Navigator.push(       // Navigate to the UserDetailPage and pass the data received from the API
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailPage(data: data),
      ),
    );
  } else {
    setState(() {
      _errorMessage = 'Invalid username or password.'; //authentication failed
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
                style: const TextStyle(color: Colors.blue),
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

  @override
  void initState() {
    super.initState();
    _getUserID();
  }
  Future<String?> _getUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID =  prefs.getString('userId') ?? '';
    setState(() {
    });
    // print(userID);
    _fetchUserDetails();
  }
 
  Future<void> _fetchUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID =  prefs.getString('userId') ?? '';
    String token =  prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('http://192.168.1.17:8000/user/$userID/'), 
      headers: {'Authorization': 'token $token'},
    );
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      final userDetails = jsonDecode(response.body);
      setState(() {
        print("SUCCESS");
        // You can access user details like userDetails['name'], userDetails['email'], etc.
      });
    } else {
      // Handle API error
      setState(() {
        print("API ERROR");
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    List<String> details = widget.data.toString().split(',');    // Split the data by commas

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // for (var detail in details)            // Display each detail on a new line
            //   Text(detail.trim(), style: const TextStyle(fontSize: 18)),
            Center(
              child :UserDetailItem(label: 'Username', value: widget.data['user']['username'])
              ),
            Center(
              child: UserDetailItem(label: 'Email', value: widget.data['user']['email'])
            ),
            Center(
              child: UserDetailItem(label: 'First Name', value: widget.data['user']['first_name'])
            ),
            Center(
              child: UserDetailItem(label: 'Last Name', value: widget.data['user']['last_name'])
              ),
            Center(
              child: UserDetailItem(label: 'Country', value: widget.data['user']['country'])
              ),
            Center(
              child: UserDetailItem(label: 'State', value: widget.data['user']['state'])
              ),
            Center(
              child: UserDetailItem(label: 'Profile image', value: widget.data['user']['image'])
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Navigate back to the login page
              },
              child: const Text('Back to Login'),
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
  const UserDetailItem({Key? key, required this.label, required this.value}) : super(key: key);

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