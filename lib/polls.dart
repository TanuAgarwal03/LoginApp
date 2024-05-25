import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/pollDetails.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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