// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:login_page/post_detail.dart';
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';
// // import 'package:translator/translator.dart';

// class BlogPostsPage extends StatefulWidget {
//   const BlogPostsPage({super.key});

//   @override
//   State<BlogPostsPage> createState() => _BlogPostsPageState();
// }

// class _BlogPostsPageState extends State<BlogPostsPage> {

//   // GoogleTranslator translator = GoogleTranslator();

//   List<dynamic> _posts = [];
//   bool _isLoading = false;
//   bool _hasError = false;
//   String token = '';

//   @override
//   void initState() {
//     super.initState();
//     _fetchPosts();
//   }

//   Future<void> _fetchPosts() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     token = prefs.getString('token') ?? '';
//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//     });

//     final response = await http.get(
//       Uri.parse('https://test.securitytroops.in/stapi/v1/blogs/posts/'),
//       headers: {
//         'Authorization': 'Token $token',
//       },
//     );

//     if (response.statusCode == 200) {
//       setState(() {
//         _posts = json.decode(response.body)['results'];
//         _isLoading = false;
//       });
//     } else {
//       setState(() {
//         _isLoading = false;
//         _hasError = true;
//       });
//     }
//   }

//   // void translate() {
//   //   translator.translate(sourceText);
//   // }

//   String formatTimestamp(String timestamp) {
//     DateTime dateTime = DateTime.parse(timestamp);
//     return DateFormat('MMM dd, yyyy ').format(dateTime);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _hasError
//               ? const Center(
//                   child: Text('Failed to load posts\nLogin to see the posts'),
//                 )
//               : ListView.builder(
//                   itemCount: _posts.length,
//                   itemBuilder: (context, index) {
//                     final post = _posts[index];

//                     String postTitle = post['title'].replaceAll(RegExp(r'[^\w\s]+'), '');
//                     String postTime = formatTimestamp(post['timestamp']);

//                     // translate() {
//                     //   translator.translate(postTitle , to: "hi").then((output) {
//                     //     setState(() {
//                     //       postTitle = output as String;
//                     //     });
//                     //   });
//                     // }

//                     return Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: Card.outlined(
//                             elevation: 10,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(5),
//                             ),
//                             clipBehavior: Clip.antiAliasWithSaveLayer,
//                             shadowColor: Colors.grey[300],
//                             child: InkWell(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => PostDetailPage(
//                                       slug: post['slug'],
//                                       postTitle: post['title'],
//                                     ),
//                                   ),
//                                 );
//                               },
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: <Widget>[
//                                   if (post['thumbnail'] != null &&
//                                       post['thumbnail'].isNotEmpty)
//                                     Image.network(
//                                       post['thumbnail'].startsWith('http://') ||
//                                               post['thumbnail']
//                                                   .startsWith('https://')
//                                           ? post['thumbnail']
//                                           : 'https://test.securitytroops.in/stapi/v1/blogs/posts/${post['thumbnail']}',
//                                       height: 140,
//                                       width: double.infinity,
//                                       fit: BoxFit.cover,
//                                     ),

//                                   Container(
//                                     padding: const EdgeInsets.fromLTRB(
//                                         12, 10, 12, 0),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: <Widget>[
//                                         Text(
//                                           postTitle,
//                                           style: const TextStyle(
//                                             fontSize: 18,
//                                             color: Colors.black,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                         const Divider(),
//                                         Text(
//                                          '$postTime',
//                                           textAlign: TextAlign.right,
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: Colors.grey[800],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   Container(height: 10),
//                                   // ElevatedButton(
//                                   //     onPressed: translate(),
//                                   //     child: Text('Translate')),
//                                 ],
//                               ),
//                             )
//                           )
//                         );
//                   },
//                 ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/post_detail.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:translator/translator.dart';

class BlogPostsPage extends StatefulWidget {
  const BlogPostsPage({super.key});

  @override
  State<BlogPostsPage> createState() => _BlogPostsPageState();
}

class _BlogPostsPageState extends State<BlogPostsPage> {
  GoogleTranslator translator = GoogleTranslator();

  List<dynamic> _posts = [];
  bool _isLoading = false;
  bool _hasError = false;
  String token = '';

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final response = await http.get(
      Uri.parse('https://test.securitytroops.in/stapi/v1/blogs/posts/'),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _posts = json.decode(response.body)['results'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  String formatTimestamp(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    return DateFormat('MMM dd, yyyy ').format(dateTime);
  }



  String text = "Hello , How are you ?";

  // void translate() {
  //   translator.translate(text, to: "hi").then((output) {
  //     setState(() {
  //       text = output.toString();
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? const Center(
                  child: Text('Failed to load posts\nLogin to see the posts'),
                )
              : ListView.builder(
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    final post = _posts[index];

                    String postTitle =post['title'].replaceAll(RegExp(r'[^\w\s]+'), '');
                    String postTime = formatTimestamp(post['timestamp']);

                    // translator.translate(postTitle , to: "hi").then((result) => print("Source: $postTitle \n Translated : $result"));

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: [
                          // Text(text),
                          // ElevatedButton(
                          //     onPressed: translate, child: Text('Translate')),
                          Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            shadowColor: Colors.grey[300],
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PostDetailPage(
                                      slug: post['slug'],
                                      postTitle: post['title'],
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  if (post['thumbnail'] != null &&
                                      post['thumbnail'].isNotEmpty)
                                    Image.network(
                                      post['thumbnail'].startsWith('http://') ||
                                              post['thumbnail']
                                                  .startsWith('https://')
                                          ? post['thumbnail']
                                          : 'https://test.securitytroops.in/stapi/v1/blogs/posts/${post['thumbnail']}',
                                      height: 140,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        12, 10, 12, 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          postTitle,
                                          // translator.translate(postTitle , to: "hi").then((result) => print("Source: $postTitle \n Translated : $result")).toString(),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Divider(),
                                        Text(
                                          postTime,
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(height: 10),
                                  
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}


  // Future<void> _translateTitle(int index) async {
  //   final translatedText = await translator.translate(
  //     _posts[index]['title'],
  //     to: 'hi',
  //   );
  //   setState(() {
  //     _posts[index]['title'] = translatedText.text;
  //   });
  // }
  // ElevatedButton(
  //                                   onPressed: () => _translateTitle(index),
  //                                   child: const Text('Translate to Hindi'),
  //                                 ),