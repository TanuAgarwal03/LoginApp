// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:login_page/polls.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class PollCreatorPage extends StatefulWidget {
//   final dynamic token;
//   const PollCreatorPage({super.key, required this.token});
//   @override
//   _PollCreatorPageState createState() => _PollCreatorPageState();
// }

// class _PollCreatorPageState extends State<PollCreatorPage> {
//   final _formKey = GlobalKey<FormState>();
//   TextEditingController questionController = TextEditingController();
//   TextEditingController expiryDateController = TextEditingController();
//   bool isPublic = false;
//   bool immediateDeclare = false;
//   DateTime? expiryDate;
//   List<TextEditingController> optionControllers = [];
//   List<Widget> _options = [];
//   String? formattedExpiryDate;



//   @override
//   void initState() {
//     super.initState();
//     _addOption();
//     _addOption();
//   }

//   void _addOption() {
//     final controller = TextEditingController();
//     optionControllers.add(controller);
//     _options = List.generate(optionControllers.length, (index) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: optionControllers[index],
//                 decoration: InputDecoration(
//                   border: const OutlineInputBorder(),
//                   labelText: 'Option ${index + 1}',
//                 ),
//               ),
//             ),
//             if (optionControllers.length > 2)
//               IconButton(
//                 icon: const Icon(Icons.delete),
//                 onPressed: () => _removeOption(index),
//               ),
//           ],
//         ),
//       );
//     });
//     setState(() {});
//   }


//   void _removeOption(int index) {
//     setState(() {
//       optionControllers.removeAt(index);
//       _options.removeAt(index);
//     });
//   }

//   // Future<void> _submitPoll() async {
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   final token = prefs.getString('token') ?? '';
//   //   final userId = prefs.getString('userId') ?? '';
//   //   final company = prefs.getInt('companyId') ?? 0;
//   //   if (_formKey.currentState?.validate() ?? false) {
//   //     // final options = optionControllers.map((controller) => controller.text).toList();
//   //     final pollData = {
//   //       "title": questionController.text,
//   //       "expire": formattedExpiryDate,
//   //       // "options": options,
//   //       "user" : userId,
//   //       "company": company,
//   //       "image" : '',
//   //       "public" : isPublic,
//   //       "declare" : immediateDeclare,
//   //     };

//   //     final response = await http.post(
//   //       Uri.parse('https://test.securitytroops.in/stapi/v1/polls/question/'),
//   //       headers: {
//   //         'Authorization' : 'Token $token',
//   //         'Content-Type': 'application/json',
//   //       },
//   //       body: json.encode(pollData),
//   //     );

//   //     if (response.statusCode == 201) {
//   //       print('Poll created successfully');
//   //       print(response.body);
//   //     } else {
//   //       print('Failed to create poll');
//   //     }
//   //   }
//   // }


// Future<void> _submitPoll() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   final token = prefs.getString('token') ?? '';
//   final userId = prefs.getString('userId') ?? '';
//   final company = prefs.getInt('companyId') ?? 0;

//   if (_formKey.currentState?.validate() ?? false) {
//     final pollData = {
//       "title": questionController.text,
//       "expire": formattedExpiryDate,
//       "user": userId,
//       "company": company,
//       "image": '',
//       "public": isPublic,
//       "declare": immediateDeclare,
//     };

//     final response = await http.post(
//       Uri.parse('https://test.securitytroops.in/stapi/v1/polls/question/'),
//       headers: {
//         'Authorization': 'Token $token',
//         'Content-Type': 'application/json',
//       },
//       body: json.encode(pollData),
//     );

//     if (response.statusCode == 201) {
//       print('Poll created successfully');
//       final responseData = json.decode(response.body);
//       final pollId = responseData['question'];

//       // Now post the options
//       for (var controller in optionControllers) {
//         final optionData = {
//           "question": pollId,
//           "title": controller.text,
//           // "image" : '',
//         };

//         final optionResponse = await http.post(
//           Uri.parse('https://test.securitytroops.in/stapi/v1/polls/option/'),
//           headers: {
//             'Authorization': 'Token $token',
//             'Content-Type': 'application/json',
//           },
//           body: json.encode(optionData),
//         );

//         if (optionResponse.statusCode == 201) {
//           print('Option added successfully');
//         } else {
//           print('Failed to add option');
//           print(optionResponse.body);
//         }
//       }

//       // Navigate to the PollListPage after successful creation
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => PollListPage(token: token, poll: responseData),
//         ),
//       );

//     } else {
//       print('Failed to create poll');
//       print(response.body);
//     }
//   }
// }




//   @override
//     void dispose() {
//     for (final controller in optionControllers) {
//       controller.dispose();
//     }
//     questionController.dispose();
//     expiryDateController.dispose();
//     super.dispose();
//   }

//   Future<void> selectExpiryDate(BuildContext context) async {
//   DateTime? pickedDate = await showDatePicker(
//     context: context,
//     initialDate: DateTime.now(),
//     firstDate: DateTime(2000),
//     lastDate: DateTime(2101),
//   );
//   if (pickedDate != null) {
//     TimeOfDay? pickedTime = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (pickedTime != null) {
//       setState(() {
//         expiryDate = DateTime(
//           pickedDate.year,
//           pickedDate.month,
//           pickedDate.day,
//           pickedTime.hour,
//           pickedTime.minute,
//         );
//         // Format the DateTime to the correct string format
//         formattedExpiryDate = DateFormat("yyyy-MM-ddTHH:mm").format(expiryDate!);
//         print("Formatted Expiry Date: $formattedExpiryDate");
//       });
//     }
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add New Poll'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//           children: [
//             TextFormField(
//               controller: TextEditingController(
//                 text: expiryDate != null
//                     ? "${expiryDate!.year}/${expiryDate!.month}/${expiryDate!.day}, ${expiryDate!.hour}:${expiryDate!.minute}"
//                     : "",
//               ),
//               readOnly: true,
//               decoration: InputDecoration(
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: const BorderSide(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: const BorderSide(
//                     color: Colors.grey,
//                   ),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 errorBorder: const OutlineInputBorder(
//                   borderSide: BorderSide(
//                     color: Colors.red,
//                   ),
//                 ),
//                 suffixIcon: IconButton(
//                   icon: const Icon(Icons.date_range),
//                   onPressed: (){
//                     selectExpiryDate(context);
//                   } ,
//                   ),
//                   hintText: 'dd/mm/yyyy , --:--',
//                   labelText: 'Expiry date'
//               ),

//             ),
//             const SizedBox(height: 15.0),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Checkbox(
//                   value: isPublic,
//                   onChanged: (bool? value) {
//                     setState(() {
//                       isPublic = value ?? false;
//                     });
//                   },                  
//                 ),
//                 const Text('Public'),
//                 const SizedBox(width: 100),
//                 Checkbox(
//                   value: immediateDeclare,
//                   onChanged: (bool? value) {
//                     setState(() {
//                       immediateDeclare = value ?? false;
//                     });
//                   },
//                 ),
//                 const Text('Immediate Declare Result'),
//               ],
//             ),
//             const Divider(),
//             const SizedBox(height: 10),

//             // Container(
//             //   width: MediaQuery.of(context).size.width*0.9,
//             //   child: Row(
//             //     children: [
//             //       TextField(
//             //         controller: questionController,
//             //         decoration: InputDecoration(
//             //           enabledBorder: OutlineInputBorder(
//             //             borderSide: const BorderSide(color: Colors.grey),
//             //             borderRadius: BorderRadius.circular(10),
//             //           ),
//             //           focusedBorder: OutlineInputBorder(
//             //             borderSide: const BorderSide(
//             //               color: Colors.grey,
//             //             ),
//             //             borderRadius: BorderRadius.circular(10),
//             //           ),
//             //           errorBorder: const OutlineInputBorder(
//             //             borderSide: BorderSide(
//             //               color: Colors.red,
//             //             ),
//             //           ),
//             //           labelText: 'Question Title',
//             //           hintText: 'Question Title*',
//             //         ),
//             //       ),
//             //       // IconButton(
//             //       //   onPressed: onPressed, 
//             //       //   icon: const Icon(Icons.cloud_upload)),


//             //     ],),
//             // ),
//             TextField(
//               controller: questionController,
//               decoration: InputDecoration(
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: const BorderSide(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: const BorderSide(
//                     color: Colors.grey,
//                   ),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 errorBorder: const OutlineInputBorder(
//                   borderSide: BorderSide(
//                     color: Colors.red,
//                   ),
//                 ),
//                 labelText: 'Question Title',
//                 hintText: 'Question Title*',
//               ),
//             ),

            
//             const SizedBox(height: 30.0),
//             const Text('Add Options' , style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),),
//             const SizedBox(height: 5),
            
//             ..._options,
//             const SizedBox(height: 20),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 180.0), 
//               child: ElevatedButton(
//               onPressed: _addOption,
//               style: ElevatedButton.styleFrom(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10.0)
//                 ),
//                 backgroundColor: Colors.grey[700],                
//               ),
//               child: const Text('Add Option' , style: TextStyle(color: Colors.white , fontSize: 16),),
//             ),
//             ),
            
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.transparent , 
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.0)
//                     )),
//                   onPressed: _submitPoll,
//                   child: Text('Submit' , style: TextStyle(color: Colors.grey[900] , fontWeight: FontWeight.bold),),
//                 ),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red , 
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.0)
//                     )),
//                   onPressed: () {
//                      Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const PollListPage(token: 'token', poll: {},),
//                       ),
//                     );
//                   },
//                   child: const Text('Cancel' , style: TextStyle(color:Colors.white ),),
//                 ),
//               ],
//             ),
//           ],
//         ),
// )
//               ),
//     );
//   }
// }
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; // Add this import for image picking

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
  List<Widget> _options = [];
  String? formattedExpiryDate;
  File? _image; // Variable to hold the selected image

  @override
  void initState() {
    super.initState();
    _addOption();
    _addOption();
  }

  void _addOption() {
    final controller = TextEditingController();
    optionControllers.add(controller);
    _options = List.generate(optionControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: optionControllers[index],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Option ${index + 1}',
                ),
              ),
            ),
            if (optionControllers.length > 2)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _removeOption(index),
              ),
          ],
        ),
      );
    });
    setState(() {});
  }

  void _removeOption(int index) {
    setState(() {
      optionControllers.removeAt(index);
      _options.removeAt(index);
    });
  }

  Future<void> _submitPoll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final userId = prefs.getString('userId') ?? '';
    final company = prefs.getInt('companyId') ?? 0;

    if (_formKey.currentState?.validate() ?? false) {
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
            'image' : '',
            
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

          // Now post the options
          for (var controller in optionControllers) {
            final optionData = {
              "question": pollId,
              "title": controller.text,
            };

            final optionResponse = await http.post(
              Uri.parse('https://test.securitytroops.in/stapi/v1/polls/option/'),
              headers: {
                'Authorization': 'Token $token',
                'Content-Type': 'application/json',
              },
              body: json.encode(optionData),
            );

            if (optionResponse.statusCode == 201) {
              print('Option added successfully: ${controller.text}');
            } else {
              print('Failed to add option: ${controller.text}');
              print(optionResponse.body);
            }
          }

          // Navigate to the PollListPage after successful creation
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => PollListPage(token: token, poll: responseData),
          //   ),
          // );
        } else {
          print('Failed to create poll');
          print(response.body);
        }
      } catch (e) {
        print('Error occurred: $e');
      }
    }
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

  @override
  void dispose() {
    for (final controller in optionControllers) {
      controller.dispose();
    }
    questionController.dispose();
    expiryDateController.dispose();
    super.dispose();
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
          print("Formatted Expiry Date: $formattedExpiryDate");
        });
      }
    }
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
                  const SizedBox(width: 100),
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
              TextField(
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
              ),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 180.0),
                child: ElevatedButton(
                  onPressed: _addOption,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    backgroundColor: Colors.grey[700],
                  ),
                  child: const Text(
                    'Add Option',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Pick Image'),
                  ),
                  ElevatedButton(
                    onPressed: _submitPoll,
                    child: const Text('Submit Poll'),
                  ),
                ],
              ),
              if (_image != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Image.file(_image!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
