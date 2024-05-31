import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PollDetailPage extends StatefulWidget {
  const PollDetailPage({super.key, required this.token, required this.userId, required this.poll});
  final String token;
  final String userId;
  final Map<String, dynamic> poll;

  @override
  _PollDetailPageState createState() => _PollDetailPageState();
}

class _PollDetailPageState extends State<PollDetailPage> {
  String pollQuestion = "";
  late String token;
  late String userId;
  bool _isLoading = false;
  bool _canVote = false;
  String chosenOptionId = "";
  int questionId = 0;
  String selectedOptionTitle = "";

  List<Map<String, dynamic>> pollOptions = [];

  @override
  void initState() {
    super.initState();
    token = widget.token;
    userId = widget.userId;
    pollQuestion = widget.poll['title'];
    pollOptions = List<Map<String, dynamic>>.from(widget.poll['option']);
    questionId = widget.poll['id'];
    _canVote = !widget.poll['result'];

    if (!_canVote) {
      final selectedOption = pollOptions.firstWhere(
        (option) => option['vote'] > 0,
        orElse: () => {},
      );
      chosenOptionId = selectedOption['id'].toString();
      selectedOptionTitle = selectedOption['title'];
    }
  }

  Future<void> submitAnswer(String optionId) async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('https://test.securitytroops.in/stapi/v1/polls/answer/'),
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
        selectedOptionTitle = pollOptions
            .firstWhere((option) => option['id'].toString() == optionId)['title'];
        _isLoading = false;
        _canVote = false; 
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to submit answer');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poll Details', style: TextStyle(color: Colors.white), textAlign: TextAlign.center,),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pollQuestion,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (!_canVote)
                    Column(
                      children: [
                        const Text(
                          'You have already voted for:',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          selectedOptionTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Column(
                          children: pollOptions.map<Widget>((option) {
                            return Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    option['title'],
                                    style: const TextStyle(fontSize: 18),
                                    textAlign: TextAlign.start,
                                  ),
                                  Text('${option['percent']}%'),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  if (_canVote)
                    Expanded(
                      child: ListView.builder(
                        itemCount: pollOptions.length,
                        itemBuilder: (context, index) {
                          final option = pollOptions[index];
                          return Padding(
                          
                            padding:
                                const EdgeInsets.symmetric(vertical: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                submitAnswer(option['id'].toString());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    chosenOptionId == option['id'].toString()
                                        ? Colors.green
                                        : null,
                              ),
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
