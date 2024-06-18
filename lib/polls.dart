import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/newPoll.dart';
import 'package:login_page/pollDetails.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PollListPage extends StatefulWidget {
  const PollListPage({super.key, this.token, this.userId, required this.poll});
  final dynamic token;
  final dynamic userId;
  final Map<String, dynamic> poll;

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
      Uri.parse('https://test.securitytroops.in/stapi/v1/polls/question/'),
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

  void _openCreatePollForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PollCreatorPage(token: 'token'),
      ),
    );
  }
  void refreshPollList() {
    fetchPollData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
        body: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: _openCreatePollForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                  child: const Wrap(
                    children: <Widget>[
                      Icon(Icons.add , color: Colors.white, size: 22,), 
                      SizedBox(width: 5),
                      Text('New Poll', style: TextStyle(color: Colors.white , fontSize: 16),),
                    ],
                  )
                ),
              ),
              Expanded(
                child: polls.isEmpty
                    ? const Center(child: Text('No polls available'))
                    : ListView.builder(
                        itemCount: polls.length,
                        itemBuilder: (context, index) {
                          final poll = polls[index];
                          bool result = poll['result'];
                          bool isExpired = false;
                          String expireMessage = '';
                          if (poll['expire'] != null) {
                            DateTime expireDate = DateTime.parse(poll['expire']);
                            if (expireDate.isBefore(DateTime.now())) {
                              isExpired = true;
                              expireMessage = 'Poll has expired';
                            }
                          }
                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Card.outlined(
                              elevation: 10.0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              shadowColor: Colors.grey[50],
                              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: Text(
                                      '${poll['count']} Votes',
                                      style: const TextStyle(color: Colors.green, fontSize: 14),
                                    ),
                                  ),
                                  ListTile(
                                    title: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 10.0),
                                        Text(
                                          "Created by: ${poll['users']['display']}",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          poll['title'],
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          expireMessage,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isExpired ? Colors.red : Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => PollDetailPage(
                                                  token: token,
                                                  userId: userId,
                                                  poll: poll,
                                                  refreshPollList:refreshPollList,
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            side: BorderSide(
                                              color: result ? Colors.green : Colors.blue,
                                            ),
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5.0),
                                            ),
                                          ),
                                          child: Text(
                                            result ? 'Result' : 'Vote',
                                            style: TextStyle(
                                              fontWeight: result ? FontWeight.bold : FontWeight.normal,
                                              fontSize: 16,
                                              color: result ? Colors.green : Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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
