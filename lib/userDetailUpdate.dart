import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class UpdateUserPage extends StatefulWidget {
  final String userId;
  final String token;

  const UpdateUserPage({super.key, required this.userId, required this.token});

  @override
  State<UpdateUserPage> createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _marriedController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  String? _selectedGender;
  File? _image;
  var profile;
  bool p_image = false;
  bool _isLoading = true;
  bool _isMarried = false;

  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> _states = [];
  int? _selectedCountry;
  int? _selectedState;
  List<Map<String, dynamic>> _countries = [];

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchCountries();
  }

  Future<void> _fetchUserDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://test.securitytroops.in/stapi/v1/profile/${widget.userId}/'),
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
          _dobController.text = data['dob'] ?? '';
          _statusController.text = data['status'] ?? '';
          _selectedGender = data['gender'];
          _mobileController.text = data['mobile'].toString();
          _isMarried = data['married'] == 'true' ;
          _marriedController.text = data['married'].toString();
          profile = data['image'] != null ? data['image'] : null;

          _selectedCountry = data['country'];
          _selectedState = data['state'];

          if (_selectedCountry != null) {
            _fetchStates(_selectedCountry!);
          }
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('Failed to fetch user details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // setState(() {
      //   _isLoading = false;
      // });
      print('Error fetching user details: $e');
    }
  }

  Future<void> _fetchCountries() async {
    try {
      _isLoading = true;
      final response = await http.get(
          Uri.parse('https://test.securitytroops.in/stapi/v1/geolocation/country/'));

      if (response.statusCode == 200) {
        final parsedResponse = jsonDecode(response.body);
        List<dynamic> countries = parsedResponse['results'];

        setState(() {
          _countries = countries.map<Map<String, dynamic>>((country) {
            return {
              'id': country['id'],
              'name': country['name'],
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        _isLoading = false;
        throw Exception('Failed to load countries');
      }
    } catch (e) {
      print('Error loading countries: $e');
      setState(() {
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

Future<void> _fetchStates(int countryId) async {
  try {
    final response = await http.get(
      Uri.parse('https://test.securitytroops.in/stapi/v1/geolocation/state/'),
    );

    if (response.statusCode == 200) {
      final parsedResponse = jsonDecode(response.body);
      List<dynamic> states = parsedResponse['results'];

      setState(() {
        _states = states
            .where((state) => state['country'] == countryId)
            .map<Map<String, dynamic>>((state) {
              return {
                'id': state['id'],
                'name': state['name'],
              };
            }).toList();
      });
    } else {
      throw Exception('Failed to load states');
    }
  } catch (e) {
    print('Error loading states: $e');
    setState(() {
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
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
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        p_image = true;
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _getImageFromCamera() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
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
    if (_formKey.currentState?.validate() ?? false){
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String dob = _dobController.text.trim();
    String gender = _selectedGender ?? '';
    String mobile = _mobileController.text.trim();
    
    try {
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse(
            'https://test.securitytroops.in/stapi/v1/profile/${widget.userId}/'),
      );
      request.headers['Authorization'] = 'token ${widget.token}';
      request.fields['username'] = username;
      request.fields['email'] = email;
      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;
      request.fields['married'] = _isMarried.toString();
      request.fields['dob'] = dob;
      request.fields['gender'] = gender;
      request.fields['mobile'] = mobile;

      if (_selectedCountry != null) {
        request.fields['country'] = _selectedCountry.toString();
      }
      if (_selectedState != null) {
        request.fields['state'] = _selectedState.toString();
      }

      if (_image != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', _image!.path));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final updatedData = jsonDecode(responseBody);
        Navigator.pop(context, updatedData);
        print("Details updated");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Details updated successfully !!' , style: TextStyle(color: Colors.white),),
              backgroundColor: Colors.green,
              margin: EdgeInsets.all(5),
              elevation: 10,
              behavior: SnackBarBehavior.floating,
            ),
          );
      } else {
        print('Failed to update user details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating user details: $e');
    }
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Update User Details', style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.blue,
          iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Container(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
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
                                      errorBuilder: (BuildContext context , Object exception , StackTrace? stackTrace) {
                                        return const Icon(Icons.person_4_rounded ); 
                                      }
                                    )
                                  : Image.network(
                                      '$profile',
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (BuildContext context , Object exception , StackTrace? stackTrace) {
                                        return const Icon(Icons.person_4_rounded ); 
                                      }
                                    ),
                            ),
                          ),
                        ),
                        const Center(
                          child: Text('User Profile'),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _usernameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Username field cannot be empty';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 90, 89, 89)),
                            ),
                            labelText: 'Username',                            
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 90, 89, 89)),
                            ),
                            labelText: 'Email',                            
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _firstNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your first name';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 90, 89, 89)),
                            ),
                            labelText: 'First Name',                            
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _lastNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your last name';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 90, 89, 89)),
                            ),
                            labelText: 'Last Name',                            
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _dobController,
                          readOnly: true,
                          onTap: () =>
                              _selectDate(context),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 90, 89, 89)),
                            ),
                            labelText: 'Date of Birth',                            
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _mobileController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'This is the required field* .';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 90, 89, 89)),
                            ),
                            labelText: 'Contact',                            
                          ),
                          keyboardType: TextInputType.phone,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                        ),
                        const SizedBox(height: 15),
                        
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          items: const [
                            DropdownMenuItem(value: 'Male', child: Text('Male')),
                            DropdownMenuItem(
                                value: 'Female', child: Text('Female')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 90, 89, 89)),
                            ),
                            labelText: 'Gender',                            
                          ),
                        ),
                        const SizedBox(height: 15),

                        CheckboxListTile(
                          title: const Text('Married'),
                          value: _isMarried,
                          onChanged: (bool? value) {
                            setState(() {
                              _isMarried = value!;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),

                        const SizedBox(height: 15),
                        DropdownButtonFormField<int>(
                          hint: const Text('Select country'),
                          value: _selectedCountry,
                          onChanged: (int? value) {
                            setState(() {
                              _selectedCountry = value;
                              _selectedState = null;
                              _states = [];
                            });
                            print(_selectedCountry);
                            if (value != null) {
                              _fetchStates(value);
                            }
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a country';
                            }
                            return null;
                          },
                          items: _countries.map<DropdownMenuItem<int>>((country) {
                            return DropdownMenuItem<int>(
                              key: Key(country['name']),
                              value: country['id'],
                              child: Text(country['name']),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 90, 89, 89)),
                            ),
                            labelText: 'Country',                            
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          hint: const Text('Select State'),
                          value: _selectedState,
                          onChanged: (int? value) {
                            setState(() {
                              _selectedState = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a state';
                            }
                            return null;
                          },
                          items: _states.map<DropdownMenuItem<int>>((state) {
                            return DropdownMenuItem<int>(
                              key: Key(state['name']),
                              value: state['id'],
                              child: Text(state['name']),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 90, 89, 89)),
                            ),
                            labelText: 'State',                            
                          ),
                        ),

                        const SizedBox(height: 25),                        
                        Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton(
                            onPressed: _updateUserDetails,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              )
                            ),
                            child: const Text('Save Changes' , style: TextStyle(color: Colors.white , fontSize: 16),)
                          ),
                        )
                        
                      ]),
                    )
                  )
                )
              );
  }
}
