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
  String? imagePoll;

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
    imagePoll = widget.poll['image'];

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
        title: const Text(
          'Poll Details',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pollQuestion,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    imagePoll != null
                        ? Image.network(imagePoll! , 
                        height: MediaQuery.of(context).size.height*0.3,width: MediaQuery.of(context).size.width
                        )
                        : Container(),
                    const SizedBox(height: 10),
                    if (!_canVote)
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'You have already voted for : ',
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
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: pollOptions.map<Widget>((option) {
                              return Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        option['image'] != null
                                            ? Image.network(
                                                option['image'],
                                                height: 80,
                                                width: 150,
                                              )
                                            : Container(
                                                width: 200,
                                              ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      20.0, 10.0, 20.0, 0.0),
                                              child: Text(
                                                option['title'],
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.grey[850]),
                                                textAlign: TextAlign.start,
                                              ),
                                            ),
                                            Text(
                                              '${option['percent']}%',
                                              style: TextStyle(
                                                  color: Colors.green[900],
                                                  fontSize: 12,
                                                  fontWeight:
                                                      FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20.0, right: 20.0),
                                      child: LinearProgressIndicator(
                                        value: (option['percent']) / 100,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                Colors.blue),
                                        minHeight: 6.0,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20.0),
                                      child: Text(
                                        "${option['vote']} votes",
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10.0)
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    if (_canVote)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: pollOptions.length,
                        itemBuilder: (context, index) {
                          final option = pollOptions[index];
                          bool _isExpired = false;
                          String expireMessage = '';
                          if (widget.poll['expire'] != null) {
                            DateTime expireDate =
                                DateTime.parse(widget.poll['expire']);
                            if (expireDate.isBefore(DateTime.now())) {
                              _isExpired = true;
                              expireMessage = 'Poll has expired';
                            }
                          }
                          return Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: ListTile(
                                title: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isExpired ? expireMessage : '',
                                      style: const TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                    Text(
                                        '${option['title']}   -   ${option['percent']}%',
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    const SizedBox(height: 10.0)
                                  ],
                                ),
                                subtitle: ElevatedButton(
                                  onPressed: () {
                                    submitAnswer(
                                        option['id'].toString());
                                  },
                                  style: ElevatedButton.styleFrom(
                                      side: BorderSide(
                                        color: chosenOptionId ==
                                                option['id'].toString()
                                            ? Colors.green
                                            : Colors.blue,
                                      ),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      backgroundColor: Colors.white),
                                  child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            option['title'],
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18),
                                          )
                                        ],
                                      )),
                                ),
                              ));
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
