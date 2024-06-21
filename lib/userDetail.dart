import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import 'package:login_page/apiService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_page/userDetailUpdate.dart';


class UserDetailPage extends StatefulWidget {
  final dynamic token;
  final dynamic userId;
  const UserDetailPage({super.key, required this.userId, required this.token});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  late String userID;
  late String token;
  Map userdata = {};
  bool _isLoading = false;
  ApiService apiService = ApiService();


  
  @override
  void initState() {
    super.initState();
    userID = widget.userId;
    token = widget.token;
    _getUserData();
  }

  Future<void> _getUserData() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? token;
    userID = prefs.getString('userId') ?? userID;

    final response = await apiService.getAPI('profile/');
    
    // final response = await http.get(Uri.parse('https://test.securitytroops.in/stapi/v1/profile/'),
    //   headers: {
    //     'Authorization': 'Token $token',
    //   },
    // );

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
      // appBar: AppBar(
      //   title: const Text('User Details'),
      // ),
      body:  _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            child: _buildUserDetailPage(context),
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
            margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
            child: Column(             
              children: [
                const SizedBox(height: 20.0),
                if (userdata['image'] != null && userdata['image'].isNotEmpty)
                  Center(
                    child: ClipOval(
                      child: Image.network(
                        userdata['image'].startsWith('http://') || userdata['image'].startsWith('https://')
                            ? userdata['image']
                            : 'https://test.securitytroops.in/stapi/v1/profile/${userdata['image']}',
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (BuildContext context , Object exception , StackTrace? stackTrace) {
                          return const Icon(Icons.account_circle_rounded);
                        },
                      ),
                    ),
                  ),
                if (userdata['image'] == null || userdata['image'].isEmpty)
                  const Center(
                    child: Text('No Image Available', style: TextStyle(fontSize: 18)),
                  ),
                const SizedBox(height: 35),
                UserDetailItem(
                  label: 'Username',
                  value: userdata['username'],
                ),
                UserDetailItem(
                  label: 'Email',
                  value: userdata['email'],
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
                  label: 'Date of Birth',
                  value: userdata['dob'] ?? '',
                ),
                UserDetailItem(
                  label: 'Gender',
                  value: userdata['gender'] ?? '',
                ),
                UserDetailItem(
                  label: 'Marital Status',
                  value: userdata['married'] ? 'Married' : 'Single',
                ),
                UserDetailItem(
                  label: 'Contact',
                  value: userdata['mobile'].toString(),
                  ),
                UserDetailItem(
                  label: 'Country',
                  value: userdata['countries']['name']
                  ),
                UserDetailItem(
                  label: 'State', 
                  value: userdata['states']['name'])

              ],
            ),
          ),
          const SizedBox(height: 15),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                )
              ),
              child: const Text('Edit User Details' , style: TextStyle(color: Colors.white),),
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

