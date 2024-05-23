import 'package:flutter/material.dart';
import 'package:login_page/home_page.dart';
import 'package:login_page/polls.dart';
// import 'package:login_page/polls.dart';
import 'package:login_page/userDetail.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      home: LoginPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required String token, required String userId});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const PollPage(token: 'token'),
    const UserDetailPage(userId: 'userId', token: 'token'),
    // PollPage(),  // Added PollsPage
    const LoginPage(),
  ];

  static const List<String> _appBarTitles = ['Polls', 'User Detail', 'Login'];

  void _onItemTapped(int index) {
    if(index == 2) {
      _logout();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
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
        title: Text(_appBarTitles[_selectedIndex]), 
        backgroundColor: Colors.lightBlue[50],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'UserDetail',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.poll),
          //   label: 'Polls',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        backgroundColor: Colors.lightBlue[50],
        onTap: _onItemTapped,
      ),
    );
  }
}
