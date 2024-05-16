import 'package:flutter/material.dart';
import 'package:login_page/homePage.dart';
import 'package:login_page/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_page/userDetailUpdate.dart';

const String baseURL = 'http://192.168.1.26:8000';

class UserDetailPage extends StatefulWidget {
  final dynamic data;
  const UserDetailPage({super.key, required this.data});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  late String userID = '';
  late String token = '';
  late Map<String, dynamic> userdata;
  int _selectedIndex = 1; // Initially show the UserDetailPage

  @override
  void initState() {
    super.initState();
    _getUserID();
    userdata = widget.data['user'];
  }

  Future<void> _getUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = prefs.getString('userId') ?? '';
    token = prefs.getString('token') ?? '';
    setState(() {});
    print(token);
  }

  void _onItemTapped(int index) {
    if(index == 2) {
      setState(() {
        _selectedIndex = 1;
      });
      _logout();
    }
    else{
      setState(() {
      _selectedIndex = index;
    });
    } 
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => LoginPage())
    );
  }
  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = <Widget>[
      HomePage(),
      _buildUserDetailPage(context),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 182, 217, 233),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout'
          )
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildUserDetailPage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
            child: Column(
              children: [
                if (userdata['image'] != null && userdata['image'].isNotEmpty)
            Center(
              child: ClipOval(
                child: Image.network(
                userdata['image'].startsWith('http://') || userdata['image'].startsWith('https://')
                    ? userdata['image']
                    : '$baseURL${userdata['image']}',
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
              )
            ),
            if (userdata['image'] == null || userdata['image'].isEmpty)
              const Center(
                child: Text('No Image Available', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 35),
                UserDetailItem(
                  label: 'Username',
                  value: userdata['username'] ?? '',
                ),
                UserDetailItem(
                  label: 'Email',
                  value: userdata['email'] ?? '',
                ),
                UserDetailItem(
                  label: 'First Name',
                  value: userdata['first_name'] ?? '',
                ),
                UserDetailItem(
                  label: 'Last Name',
                  value: userdata['last_name'] ?? '',
                ),
                UserDetailItem(
                  label: 'Country',
                  value: userdata['country'] ?? '',
                ),
                UserDetailItem(
                  label: 'State',
                  value: userdata['state'] ?? '',
                ),
                UserDetailItem(
                  label: 'Date of Birth',
                  value: userdata['dob'] ?? 'N/A',
                ),
              ],
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                final updatedData = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateUserPage(
                      userId: userID,
                      token: token,
                    ),
                  ),
                );
                if (updatedData != null) {
                  setState(() {
                    userdata = updatedData;
                  });
                }
              },
              child: const Text('Update User Details'),
            ),
          ),
          const SizedBox(height: 10),
        ],
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


