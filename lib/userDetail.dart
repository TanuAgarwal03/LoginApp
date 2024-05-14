import 'package:flutter/material.dart';
import 'package:login_page/userDetailUpdate.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  late Map<String,dynamic> userdata;

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
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.2),
              child: Column(
                children: [
                  UserDetailItem(
                    label: 'Username',
                    // value: widget.data['user']['username'],
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
                  )
                ],
              ),
            ),
            Center(
              child: ElevatedButton(
              onPressed: () async {
                final updatedData = await Navigator.push( //push the data to corresponding fields
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
            
            const SizedBox(height: 10), //for spacing between the buttons

            Center(
              child:ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back to Login'),
            ),
            )
          ],
        ),
      ),
    );
  }
}



  // Future<void> _fetchUserDetails() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String userID = prefs.getString('userId') ?? '';

  //   final response = await http.get(
  //     Uri.parse('http://192.168.1.26:8000/user/$userID/'),
  //     headers: {'Authorization': 'token $token'},
  //   );

  //   if (response.statusCode == 200) {
  //     final userDetails = jsonDecode(response.body);
  //     setState(() {
  //       userdata = userDetails;
  //       print("SUCCESS");
  //     });
  //   } else {
  //     setState(() {
  //       print("API ERROR");
  //     });
  //   }
  // }
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
                    ? Image.network(isValidURL ? value : '$baseURL$value', height: 100, width: 30, fit: BoxFit.cover)
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
