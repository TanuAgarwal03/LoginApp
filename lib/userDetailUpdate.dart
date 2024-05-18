import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';

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
  var profile;
  bool p_image = false;
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
        Uri.parse('http://192.168.124.100:8000/user/${widget.userId}/'),
        headers: {
          'Authorization': 'token ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _isLoading = false;
          _usernameController.text = data['username'] ?? '';
          _emailController.text = data['email'] ?? '';
          _firstNameController.text = data['first_name'] ?? '';
          _lastNameController.text = data['last_name'] ?? '';
          _countryController.text = data['country'] ?? '';
          _stateController.text = data['state'] ?? '';
          _dobController.text = data['dob'] ?? '';

          profile = data['image'] != null ? data['image'] : null;

          // if (data['image'] != null) {
          //   // _downloadImage(data['image']);
          // }else {
          //   _isLoading = false;
          // }
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print(
            'Failed to fetch user details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        p_image = true;
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _getImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        p_image = true;
        _image = File(pickedFile.path);
      });
    }
  }

  Future showOptions() async {
  showCupertinoModalPopup(
    context: context,
    builder: (context) => CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          child: const Text('Photo Gallery'),
          onPressed: () {
            Navigator.of(context).pop();
            _pickImage();
          },
        ),
        CupertinoActionSheetAction(
          child: const Text('Camera'),
          onPressed: () {
            Navigator.of(context).pop();
            _getImageFromCamera();
          },
        ),
      ],
    ),
  );
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
        Uri.parse('http://192.168.124.100:8000/user/${widget.userId}/'),
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
        request.files
            .add(await http.MultipartFile.fromPath('image', _image!.path));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final updatedData = jsonDecode(responseBody);
        Navigator.pop(
            context, updatedData); // Sending the updated data to userDetailPage
        print("Details updated");
      } else {
        print(
            'Failed to update user details. Status code: ${response.statusCode}');
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
                    Center(
                      child: GestureDetector(
                        onTap: showOptions,
                        child: ClipOval(
                                child: p_image
                                    ? Image.file(
                                        _image!,
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        '$profile',
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                      ),
                    ),
                    const Center(
                      child: Text('User Profile'),
                    ),
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
                      decoration:
                          const InputDecoration(labelText: 'First Name'),
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
                      onTap: () =>
                          _selectDate(context), // Trigger date picker on tap
                      decoration:
                          const InputDecoration(labelText: 'Date of Birth'),
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