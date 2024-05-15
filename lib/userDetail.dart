import 'package:flutter/material.dart';
import 'package:login_page/homePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_page/userDetailUpdate.dart';
import 'homePage.dart'; // Import the HomePage widget

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
    // _fetchUserDetails();
    print(token);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
                  label: 'Profile image',
                  value: userdata['image'] ?? '',
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
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back to Login'),
            ),
          ),
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
    final bool isProfileImage = label == 'Profile image';
    final bool isValidURL = value.startsWith('http://') || value.startsWith('https://');

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
            child: isProfileImage
                ? value.isNotEmpty
                    ? Image.network(isValidURL ? value : '$baseURL$value', height: 200, width: 10, fit: BoxFit.cover)
                    : const Text('No Image Available')
                : Text(
                    value,
                    style: const TextStyle(fontSize: 18),
                  ),
          ),
        ],
      ),
    );
  }
}
