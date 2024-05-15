import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

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

  File? _image;
  
  bool _isLoading = true;

  final ImagePicker _picker = ImagePicker();

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

          _image = data['image'] != null ? File(data['image']) : null;

          if (data['image'] != null) {
            _downloadImage(data['image']);
          }else {
            _isLoading = false;
          }
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
        _dobController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }


  Future<void> _downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final documentDirectory = await getApplicationDocumentsDirectory();
        final file = File('${documentDirectory.path}/profile_image.png');
        file.writeAsBytesSync(response.bodyBytes);

        setState(() {
          _image = file;
          _isLoading = false;
        });
      } else {
        print('Failed to download image. Status code : ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading image: $e');
    }
  }


  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateUserDetails() async {
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String country = _countryController.text.trim();
    String state = _stateController.text.trim();
    String dob = _dobController.text.trim();

    try {
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('http://192.168.1.26:8000/user/${widget.userId}/'),
      );
      request.headers['Authorization'] = 'token ${widget.token}';
      request.fields['username'] = username;
      request.fields['email'] = email;
      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;
      request.fields['country'] = country;
      request.fields['state'] = state;
      request.fields['dob'] = dob;

      if (_image != null) {
        // String image;
        request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final updatedData = jsonDecode(responseBody);
        Navigator.pop(context, updatedData); // Sending the updated data to userDetailPage
        print("Details updated");
      } else {
        print('Failed to update user details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating user details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update User Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Display loader
          : Container(
              // margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.3),
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    
                    const Text('Profile image', textAlign: TextAlign.right,) , 
                    const Text('Tap on image to choose new file'),
                    const SizedBox(height:10),                 
                    GestureDetector(
                      onTap: _pickImage,
                      child: _image == null
                          ? const Text('No image selected.')
                          : Image.file(_image!, height: 100, width: 100),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                      onPressed: _updateUserDetails,
                      child: const Text('Update'),
                    ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}



//for image picker -Multipart is used , pickImage(source), 