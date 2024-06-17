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

  final List<Widget> _widgetOptions = <Widget>[
    const BlogPostsPage(),
    const PollListPage(token: 'token', poll: {}),
    const UserDetailPage(userId: 'userId', token: 'token'),
    const ChangePasswordPage(),
  ];

  static const List<String> _appBarTitles = ['Blogs', 'Polls', 'User Detail', 'Change Password'];

  void _onItemTapped(int index) {
    setState(() {
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
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Blogs'),
              onTap: () {
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
                _onItemTapped(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.key_rounded),
              title: const Text('Change Password'),
              onTap: () {
                _onItemTapped(3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                _logout();
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
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
        // currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        backgroundColor: Colors.lightBlue[50],
        onTap: (index) {
          if (index == 1) {
            _logout();
          } else {
            BlogPostsPage();
          }
          
        },
      ),
    );
  }
}
