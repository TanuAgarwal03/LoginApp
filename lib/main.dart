import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:login_page/change_password.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_page/home_page.dart';
import 'package:login_page/polls.dart';
import 'package:login_page/userDetail.dart';
import 'login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, 
      home: LoginPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.token, required this.userId});

  final String token;
  final String userId;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  bool _isLoading = false;
  late String userID;
  late String token;
  Map userdata = {};

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  final List<Widget> _widgetOptions = <Widget>[
    const BlogPostsPage(),
    const PollListPage(token: '', poll: {}),
    const UserDetailPage(userId: '', token: ''),
    const ChangePasswordPage(),
  ];

  static const List<String> _appBarTitles = ['Blogs', 'Polls', 'User Detail', 'Change Password'];

  void _onItemTapped(int index) {
    setState(() {
      _isLoading = true;
      _selectedIndex = index;
    });
    Navigator.pop(context); // Close the drawer after selecting an item
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _getUserData() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? widget.token;
    userID = prefs.getString('userId') ?? widget.userId;

    final response = await http.get(Uri.parse('https://test.securitytroops.in/stapi/v1/profile/'),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        userdata = jsonDecode(response.body)['results'][0];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex], style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (userdata['image'] != null && userdata['image'].isNotEmpty)
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                        userdata['image'].startsWith('http://') || userdata['image'].startsWith('https://')
                            ? userdata['image']
                            : 'https://test.securitytroops.in/stapi/v1/profile/${userdata['image']}',
                      ),
                      onBackgroundImageError: (_, __) => const Icon(Icons.account_circle_rounded),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            userdata['username'] ?? 'Username',
                            style: const TextStyle(color: Colors.white, fontSize: 18 , fontWeight: FontWeight.bold),
                          ),
                          Text(
                            userdata['email'] ?? 'Email',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout_rounded, color: Colors.white),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Blogs'),
              onTap: () {
                _isLoading = true;
                _onItemTapped(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.poll),
              title: const Text('Polls'),
              onTap: () {
                _onItemTapped(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: const Text('User Detail'),
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.key_rounded),
              title: const Text('Change Password'),
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });
                Navigator.pop(context); // Close the drawer
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Blogs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.poll_sharp),
            label: 'Polls',
          ),
        ],
        currentIndex: _selectedIndex < 2 ? _selectedIndex : 0,
        selectedItemColor: Colors.blue,
        backgroundColor: Colors.lightBlue[50],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
