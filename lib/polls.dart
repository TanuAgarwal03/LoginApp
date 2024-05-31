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

  // @override
  // Widget build(BuildContext context) {
    
  //   if (_isLoading) {
  //     return const Scaffold(
  //       body: Center(child: CircularProgressIndicator()),
  //     );
  //   } else {
  //     return Scaffold(
  //     appBar: AppBar(
        // title: const Text('Polls', style: TextStyle(color: Colors.white), textAlign: TextAlign.center,),
        // backgroundColor: Colors.blue,
        // iconTheme: const IconThemeData(
        //   color: Colors.white,
        // ),
  //     ),
  //       body: polls.isEmpty
  //           ? const Center(child: Text('No polls available'))
  //           : ListView.builder(
  //               itemCount: polls.length,
  //               itemBuilder: (context, index) {
  //                 final poll = polls[index];
  //                 return ListTile(
  //                   title: Text(poll['title']),
  //                   onTap: () {
  //                     Navigator.push(
  //                       context,
  //                       MaterialPageRoute(
  //                         builder: (context) => PollDetailPage(
  //                           token: token,
  //                           userId: userId,
  //                           poll: poll,
  //                         ),
  //                       ),
  //                     );
  //                   },
  //                 );
  //               },
  //             ),
  //     );
  //   }
  // }

   @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Polls', style: TextStyle(color: Colors.white), textAlign: TextAlign.center,),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Polls', style: TextStyle(color: Colors.white), textAlign: TextAlign.center,),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        ),
        body: Container(
          color: Colors.white,
          child: polls.isEmpty
            ? const Center(child: Text('No polls available'))
            : ListView.builder(
                itemCount: polls.length,
                itemBuilder: (context, index) {
                  final poll = polls[index];
                  return Padding(padding: const EdgeInsets.all(5.0),
                  child:Card.outlined(
                    elevation: 10.0,
                    color: Color.fromARGB(255, 209, 228, 243),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    clipBehavior: Clip.antiAliasWithSaveLayer,

                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      title: Text(
                        poll['title'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding (padding: const EdgeInsets.fromLTRB(150.0, 8.0, 10.0, 0),
                      child: ElevatedButton(
                        onPressed: (){
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
                        style: ElevatedButton.styleFrom(
                          // minimumSize: const Size(10.0, 20.0),
                          backgroundColor: Color.fromARGB(255, 162, 203, 233),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)
                          )
                        ),
                        child: const Text('Tap to vote' , style: TextStyle(color: Colors.black , fontSize: 16),)),
                        ),
                        
                      // onTap: () {
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) => PollDetailPage(
                      //         token: token,
                      //         userId: userId,
                      //         poll: poll,
                      //       ),
                      //     ),
                      //   );
                      // },
                    ),
                    
                    
                  )
                  );
                   
                },
              ),
      )
      );
    }
  }
}