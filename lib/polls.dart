// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import 'package:shared_preferences/shared_preferences.dart';

// class PollPage extends StatefulWidget {
//   const PollPage({super.key, this.token, this.userId});
//   final dynamic token;
//   final dynamic userId;

//   @override
//   _PollPageState createState() => _PollPageState();
// }

// class _PollPageState extends State<PollPage> {
//   String pollQuestion = "";
//   late String token;
//   late String userId;
//   bool _isLoading = false;
//   bool _canVote = false;
//   String chosenOptionId = "";
//   int questionId = 0;

//   List<Map<String, dynamic>> pollOptions = [];

//   @override
//   void initState() {
//     super.initState();
//     token = widget.token;
//     fetchPollData();
//   }

//   Future<void> fetchPollData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     token = prefs.getString('token') ?? token;
//     userId = prefs.getString('userId') ?? userId;
//     setState(() {
//       _isLoading = true;
//     });

//     final response = await http.get(
//       Uri.parse('http://3.110.219.27:8005/stapi/v1/polls/question/'),
//       headers: {
//         'Authorization': 'token $token',
//       },
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body)['results'];
//       if (data.isNotEmpty) {
//         final poll = data[0]; // Assuming we take the first poll in the list
//         setState(() {
//           pollQuestion = poll['title'];
//           pollOptions = List<Map<String, dynamic>>.from(poll['option']);
//           questionId = poll['id'];
//           _canVote = !poll['result']; // Check if the user can vote
//           _isLoading = false;
//         });
//       }
//     } else {
//       setState(() {
//         _isLoading = false;
//       });
//       throw Exception('Failed to load poll data');
//     }
//   }

//   Future<void> submitAnswer(String optionId) async {
//     setState(() {
//       _isLoading = true;
//     });

//     final response = await http.post(
//       Uri.parse('http://3.110.219.27:8005/stapi/v1/polls/answer/'),
//       headers: {
//         'Authorization': 'token $token',
//         'Content-Type': 'application/json',
//       },
//       body: json.encode({
//         'user': userId,
//         'question': questionId,
//         'option': optionId,
//         'locate': '',
//       }),
//     );

//     if (response.statusCode == 200) {
//       setState(() {
//         chosenOptionId = optionId;
//         _isLoading = false;
//       });
//     } else {
//       setState(() {
//         _isLoading = false;
//       });
//       throw Exception('Failed to submit answer');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     } else {
//       return Scaffold(
//         body: pollQuestion.isEmpty
//             ? const Center(child: Text('No poll available'))
//             : Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       pollQuestion,
//                       style: const TextStyle(
//                           fontSize: 20, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 16),
//                     if (!_canVote)
//                       const Text(
//                         'You have already voted',
//                         style: TextStyle(
//                           color: Colors.green,
//                           fontSize: 16,
//                         ),
//                       ),
//                       // Text(),
//                     Expanded(
//                       child: ListView.builder(
//                         itemCount: pollOptions.length,
//                         itemBuilder: (context, index) {
//                           final option = pollOptions[index];
//                           return Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 8.0),
//                             child: ElevatedButton(
//                               onPressed: _canVote
//                                   ? () {
//                                       submitAnswer(option['id'].toString());
//                                     }
//                                   : null,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: chosenOptionId == option['id'].toString()
//                                     ? Colors.green
//                                     : null,
//                               ),
//                               child: Text(option['title']),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//       );
//     }
//   }
// }





// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:login_page/pollDetails.dart';
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

// class PollPage extends StatefulWidget {
//   const PollPage({super.key, this.token, this.userId});
//   final dynamic token;
//   final dynamic userId;

//   @override
//   _PollPageState createState() => _PollPageState();
// }

// class _PollPageState extends State<PollPage> {
//   String pollQuestion = "";
//   late String token;
//   late String userId;
//   bool _isLoading = false;
//   bool _canVote = false;
//   String chosenOptionId = "";
//   int questionId = 0;
//   String selectedOptionTitle = "";

//   List<Map<String, dynamic>> pollOptions = [];

//   @override
//   void initState() {
//     super.initState();
//     token = widget.token;
//     fetchPollData();
//   }

//   Future<void> fetchPollData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     token = prefs.getString('token') ?? token;
//     userId = prefs.getString('userId') ?? userId;
//     setState(() {
//       _isLoading = true;
//     });

//     final response = await http.get(
//       Uri.parse('http://3.110.219.27:8005/stapi/v1/polls/question/'),
//       headers: {
//         'Authorization': 'token $token',
//       },
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body)['results'];
//       if (data.isNotEmpty) {
//         final poll = data[0]; // Assuming we take the first poll in the list
//         setState(() {
//           pollQuestion = poll['title'];
//           pollOptions = List<Map<String, dynamic>>.from(poll['option']);
//           questionId = poll['id'];
//           _canVote = !poll['result']; // Check if the user can vote
//           if (!_canVote) {
//             final selectedOption = pollOptions.firstWhere(
//               (option) => option['vote'] > 0,
//               orElse: () => {},
//             );
//             chosenOptionId = selectedOption['id'].toString();
//             selectedOptionTitle = selectedOption['title'];
//           }
//           _isLoading = false;
//         });
//       }
//     } else {
//       setState(() {
//         _isLoading = false;
//       });
//       throw Exception('Failed to load poll data');
//     }
//   }

//   Future<void> submitAnswer(String optionId) async {
//     setState(() {
//       _isLoading = true;
//     });

//     final response = await http.post(
//       Uri.parse('http://3.110.219.27:8005/stapi/v1/polls/answer/'),
//       headers: {
//         'Authorization': 'token $token',
//         'Content-Type': 'application/json',
//       },
//       body: json.encode({
//         'user': userId,
//         'question': questionId,
//         'option': optionId,
//         'locate': '',
//       }),
//     );

//     if (response.statusCode == 200) {
//       setState(() {
//         chosenOptionId = optionId;
//         selectedOptionTitle = pollOptions
//             .firstWhere((option) => option['id'].toString() == optionId)['title'];
//         _isLoading = false;
//       });
//     } else {
//       setState(() {
//         _isLoading = false;
//       });
//       throw Exception('Failed to submit answer');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(
//         body: Center(child: Text('No data available')),
//       );
//     } else {
//       return Scaffold(
//         body: pollQuestion.isEmpty
//             ? const Center(child: Text('No poll available'))
//             : Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       pollQuestion,
//                       style: const TextStyle(
//                           fontSize: 20, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 16),
//                     if (!_canVote)
//                       Column(
//                         children: [
//                           const Text(
//                             'You have already voted',
//                             textAlign: TextAlign.start,
//                             style: TextStyle(
//                               color: Colors.green,
//                               fontSize: 16,                              
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           Column(
//                             children: pollOptions.map<Widget>((option) {
//                               return Padding(
//                                 padding: const EdgeInsets.all(2.0),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  
//                                   children: [
//                                     Text(option['title'] , style: const TextStyle(fontSize: 18) , textAlign: TextAlign.start,),
//                                     Text('${option['percent']}%'),
//                                   ],
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                         ],
//                       ),
//                     if (_canVote)
//                       Expanded(
//                         child: ListView.builder(
//                           itemCount: pollOptions.length,
//                           itemBuilder: (context, index) {
//                             final option = pollOptions[index];
//                             return Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 8.0),
//                               child: ElevatedButton(
//                                 onPressed: () {
//                                   submitAnswer(option['id'].toString());
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: chosenOptionId == option['id'].toString()
//                                       ? Colors.green
//                                       : null,
//                                 ),
//                                 child: Text(option['title']),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//       );
//     }
//   }
// }







import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/pollDetails.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// import 'pollDetails.dart'; // Import the detail page

class PollListPage extends StatefulWidget {
  const PollListPage({super.key, this.token, this.userId});
  final dynamic token;
  final dynamic userId;

  @override
  _PollListPageState createState() => _PollListPageState();
}

class _PollListPageState extends State<PollListPage> {
  late String token;
  late String userId;
  bool _isLoading = false;
  List<Map<String, dynamic>> polls = [];

  @override
  void initState() {
    super.initState();
    token = widget.token;
    fetchPollData();
  }

  Future<void> fetchPollData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? token;
    userId = prefs.getString('userId') ?? userId;
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(
      Uri.parse('http://3.110.219.27:8005/stapi/v1/polls/question/'),
      headers: {
        'Authorization': 'token $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'];
      setState(() {
        polls = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load poll data');
    }
  }

  @override
  Widget build(BuildContext context) {
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
      appBar: AppBar(
        title: Text('Polls'),
      ),
        body: polls.isEmpty
            ? const Center(child: Text('No polls available'))
            : ListView.builder(
                itemCount: polls.length,
                itemBuilder: (context, index) {
                  final poll = polls[index];
                  return ListTile(
                    title: Text(poll['title']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PollDetailPage(
                            token: token,
                            userId: userId,
                            poll: poll,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      );
    }
  }
}