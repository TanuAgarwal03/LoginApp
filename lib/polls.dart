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

    final url = 'http://3.110.219.27:8005/stapi/v1/polls/question/';
    final response = await http.get(Uri.parse(url),
    headers:{
        'Authorization' : 'token $token'
      }); 

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        setState(() {
          pollQuestion = data[0]['title'];
          pollOptions = List<Map<String, dynamic>>.from(data[0]['option']);
          _isLoading =false;
        });
      }
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
        body: Center(child: Text('No polls available')),
      );
    } else {
      return Scaffold(
      appBar: AppBar(
        title: const Text('Poll Page'),
      ),
      body: pollQuestion.isEmpty
          ? const Center(child: Text('No poll available'))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    pollQuestion,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
      );
    }
  }
}


