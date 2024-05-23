import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PollPage extends StatefulWidget {
  const PollPage({super.key, this.token, this.userId});
  final dynamic token;
  final dynamic userId;

  @override
  _PollPageState createState() => _PollPageState();
}

class _PollPageState extends State<PollPage> {
  String pollQuestion = "";
  late String token;
  late String userId;
  bool _isLoading = false;
  String chosenOptionId = "";
  int questionId = 0;
  // int optionId = 0;

  List<Map<String, dynamic>> pollOptions = [];

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
      if (data.isNotEmpty) {
        final poll = data[0]; // Assuming we take the first poll in the list
        setState(() {
          pollQuestion = poll['title'];
          pollOptions = List<Map<String, dynamic>>.from(poll['option']);
          questionId = poll['id'];
          // optionId = poll['options']['id'];
          
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load poll data');
    }
  }

  Future<void> submitAnswer(String optionId) async {
    final response = await http.post(
      Uri.parse('http://3.110.219.27:8005/stapi/v1/polls/answer/'),
      headers: {
        'Authorization': 'token $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'user': userId,
        'question': questionId,
        'option': optionId,
        'locate': '',
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        chosenOptionId = optionId;
        _isLoading = false;
      });
    } else {
      _isLoading = false;
      throw Exception('Failed to submit answer');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: Text('No polls available')),
      );
    } else {
      return Scaffold(
        body: pollQuestion.isEmpty
            ? const Center(child: Text('No poll available'))
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pollQuestion,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: pollOptions.length,
                        itemBuilder: (context, index) {
                          final option = pollOptions[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ElevatedButton(
                              // onPressed: chosenOptionId.isEmpty
                              //     ? () => submitAnswer(option['id'].toString())
                              //     : null,
                              // style: ElevatedButton.styleFrom(
                              //   backgroundColor: chosenOptionId == option['id'].toString()
                              //       ? Colors.green
                              //       : null,
                              // ),
                              onPressed: () { },
                              child: Text(option['title']),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      );
    }
  }
}
