import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:login_page/polls.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class PollCreatorPage extends StatefulWidget {
  final dynamic token;
  const PollCreatorPage({super.key, required this.token});
  @override
  _PollCreatorPageState createState() => _PollCreatorPageState();
}

class _PollCreatorPageState extends State<PollCreatorPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController questionController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();
  bool isPublic = false;
  bool immediateDeclare = false;
  DateTime? expiryDate;
  List<TextEditingController> optionControllers = [];
  List<File?> optionImages = []; 
  List<Widget> _options = [];
  String? formattedExpiryDate;
  File? _image;

  @override
  void initState() {
    super.initState();
    _addOption();
    _addOption();
  }

  void _addOption() {
    final controller = TextEditingController();
    optionControllers.add(controller);
    optionImages.add(null);

    _updateOptions();
  }

  void _updateOptions() {
    _options = List.generate(optionControllers.length, (index) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: optionControllers[index],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: 'Option ${index + 1}',
                    ),
                  ),
                ),
                const SizedBox(width: 20.0),
                IconButton(
                  icon: const Icon(Icons.cloud_upload),
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        optionImages[index] = File(pickedFile.path);
                      });
                    }
                  },
                ),
                if (optionImages[index] != null)
                  Image.file(optionImages[index]!, width: 100, height: 100),
                if (optionControllers.length > 2)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        optionControllers.removeAt(index);
                        optionImages.removeAt(index);
                      });
                      _updateOptions();
                    },
                  ),
              ],
            ),
          );
        },
      );
    });
    setState(() {});
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitPoll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final userId = prefs.getString('userId') ?? '';

    final company = prefs.getString('companyId') ?? 0;

    if (_formKey.currentState?.validate() ?? false) {
      // ignore: unused_local_variable
      final pollData = {
        "title": questionController.text,
        "expire": formattedExpiryDate,
        "user": userId,
        "company": company,
        "public": isPublic,
        "declare": immediateDeclare,
      };

      try {
        final uri = Uri.parse('https://test.securitytroops.in/stapi/v1/polls/question/');
        var request = http.MultipartRequest('POST', uri)
          ..headers.addAll({
            'Authorization': 'Token $token',
            'Content-Type': 'multipart/form-data',
          })
          ..fields.addAll({
            'title': questionController.text,
            'expire': formattedExpiryDate ?? '',
            'user': userId,
            'company': company.toString(),
            'public': isPublic.toString(),
            'declare': immediateDeclare.toString(),
            'image': '',
          });

        if (_image != null) {
          request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
        }

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 201) {
          print('Poll created successfully');
          final responseData = json.decode(response.body);
          final pollId = responseData['id'];
          print('Poll ID: $pollId');

          for (int i = 0; i < optionControllers.length; i++) {
            final controller = optionControllers[i];
            // ignore: unused_local_variable
            final optionData = {
              "question": pollId,
              "title": controller.text,
            };

            var optionRequest = http.MultipartRequest(
              'POST',
              Uri.parse('https://test.securitytroops.in/stapi/v1/polls/option/'),
            )
              ..headers.addAll({
                'Authorization': 'Token $token',
              })
              ..fields.addAll({
                'question': pollId.toString(),
                'title': controller.text,
              });

            if (optionImages[i] != null) {
              optionRequest.files.add(await http.MultipartFile.fromPath('image', optionImages[i]!.path));
            }

            final optionStreamedResponse = await optionRequest.send();
            final optionResponse = await http.Response.fromStream(optionStreamedResponse);

            if (optionResponse.statusCode == 201) {
              print('Option added successfully: ${controller.text}');
            } else {
              print('Failed to add option: ${controller.text}');
              print(optionResponse.body);
            }

          }
          Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PollListPage(token: token, poll: {},)),
        );

        } else {
          print('Failed to create poll');
          print(response.body);
        }
      } catch (e) {
        print('Error occurred: $e');
      }
    }
  }

  Future<void> selectExpiryDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          expiryDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          formattedExpiryDate = DateFormat("yyyy-MM-ddTHH:mm").format(expiryDate!);
        });
      }
    }
  }

  void _clearForm() {
    setState(() {
      questionController.clear();
      expiryDateController.clear();
      isPublic = false;
      immediateDeclare = false;
      expiryDate = null;
      formattedExpiryDate = null;
      _image = null;
      for (final controller in optionControllers) {
        controller.clear();
      }
      optionImages = List<File?>.filled(optionControllers.length, null);
    });
  }

  @override
  void dispose() {
    for (final controller in optionControllers) {
      controller.dispose();
    }
    questionController.dispose();
    expiryDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Poll'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: TextEditingController(
                  text: expiryDate != null
                      ? "${expiryDate!.year}/${expiryDate!.month}/${expiryDate!.day}, ${expiryDate!.hour}:${expiryDate!.minute}"
                      : "",
                ),
                readOnly: true,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.date_range),
                    onPressed: () {
                      selectExpiryDate(context);
                    },
                  ),
                  hintText: 'dd/mm/yyyy , --:--',
                  labelText: 'Expiry date',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Expiry date is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: isPublic,
                    onChanged: (bool? value) {
                      setState(() {
                        isPublic = value ?? false;
                      });
                    },
                  ),
                  const Text('Public'),
                  const SizedBox(width: 50),
                  Checkbox(
                    value: immediateDeclare,
                    onChanged: (bool? value) {
                      setState(() {
                        immediateDeclare = value ?? false;
                      });
                    },
                  ),
                  const Text('Immediate Declare Result'),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: questionController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                          ),
                        ),
                        labelText: 'Question Title',
                        hintText: 'Question Title*',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please Enter Question title";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  IconButton(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.cloud_upload),
                  ),
                ],
              ),
              const SizedBox(height: 15.0),
              if (_image != null) Image.file(_image!, width: 100, height: 100),
              const SizedBox(height: 30.0),
              const Text(
                'Add Options',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              const SizedBox(height: 5),
              ..._options,
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: ElevatedButton(
                      onPressed: _addOption,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                        backgroundColor: Colors.grey,
                      ),
                      child: const Text(
                        'Add Option',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: _submitPoll,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.0)),
                        backgroundColor: Color.fromARGB(255, 209, 219, 224),
                      ),
                      child: const Text('Submit')),
                  const SizedBox(width: 20.0),
                  ElevatedButton(
                      onPressed: _clearForm,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.0)),
                        backgroundColor: const Color.fromARGB(255, 212, 63, 52),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
