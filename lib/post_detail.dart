//   // Future<void> _fetchComments() async {
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   token = prefs.getString('token') ?? '';
//   //   setState(() {
//   //     _isLoading = true;
//   //   });
//   //   final response = await http.get(
//   //     Uri.parse('http://192.168.1.26:8000/comments/'),
//   //     headers: {'Authorization': 'Token $token'},
//   //   );
//   //   if (response.statusCode == 200) {
//   //     List<dynamic> allComments = json.decode(response.body)['results'];

//   //     List<dynamic> postComments = allComments
//   //         .where((comment) => comment['post']['title'] == widget.postTitle)
//   //         .toList();

//   //     setState(() {
//   //       _comments = postComments;
//   //       _isLoading = false;
//   //     });
//   //   } else {
//   //     setState(() {
//   //       _isLoading = false;
//   //     });
//   //     throw Exception('Failed to load comments');
//   //   }
//   // }

// Future<void> _fetchComments() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   token = prefs.getString('token') ?? '';
//   setState(() {
//     _isLoading = true;
//   });
//   final response = await http.get(
//     Uri.parse('http://192.168.1.26:8000/comments/'),
//     headers: {'Authorization': 'Token $token'},
//   );
//   if (response.statusCode == 200) {
//     List<dynamic> allComments = json.decode(response.body)['results'];
//     List<dynamic> postComments = allComments
//         .where((comment) => comment['post']['id'] == widget.postId)
//         .toList();

//     setState(() {
//       _comments = postComments;
//       _isLoading = false;
//     });
//   } else {
//     setState(() {
//       _isLoading = false;
//     });
//     throw Exception('Failed to load comments');
//   }
// }



//   Future<void> _addComment(String commentText) async {
//     setState(() {
//       _isLoading = true;
//     });
//     final response = await http.post(
//       Uri.parse('http://192.168.1.26:8000/comments/'),
//       headers: {
//         'Authorization': 'Token $token',
//         'Content-Type': 'application/json',
//       },
//       body: json.encode({
//         'body': commentText,
//         'post_id': widget.postId,
//         // 'name': prefs.getString('username'),
//         'name': username,
//       }),
//     );
//     if (response.statusCode == 201) {
//       setState(() {
//         _isLoading = false;
//       });
//       _fetchComments();
//     } else {
//       setState(() {
//         _isLoading = false;
//       });
//       throw Exception('Failed to add comment');
//     }
//   }

// //   Future<void> _addReply(int parentId, String replyText) async {
// //   setState(() {
// //     _isLoading = true;
// //   });
// //   final response = await http.post(
// //     Uri.parse('http://192.168.1.26:8000/comments/'),
// //     headers: {
// //       'Authorization': 'Token $token',
// //       'Content-Type': 'application/json',
// //     },
// //     body: json.encode({
// //       'body': replyText,
// //       'post_id': widget.postId,
// //       'parent_id': parentId,
// //       'name': username,
// //     }),
// //   );
// //   if (response.statusCode == 201) {
// //     setState(() {
// //       _isLoading = false;
// //     });
// //     _fetchComments();
// //   } else {
// //     setState(() {
// //       _isLoading = false;
// //     });
// //     throw Exception('Failed to add reply');
// //   }
// // }


//   // @override
//   // Widget build(BuildContext context) {
//   //   if (_isLoading) {
//   //     return Scaffold(
//   //       appBar: AppBar(title: const Text('Post Detail')),
//   //       body: const Center(child: CircularProgressIndicator()),
//   //     );
//   //   } else if (_hasError) {
//   //     return Scaffold(
//   //       appBar: AppBar(title: const Text('Post Detail')),
//   //       body: const Center(child: Text('Failed to load post details')),
//   //     );
//   //   } else {
//   //     return Scaffold(
//   //         appBar: AppBar(title: const Text('Post Detail')),
//   //         body: SingleChildScrollView(
//   //           child: _post != null
//   //               ? Padding(
//   //                   padding: const EdgeInsets.all(22),
//   //                   child: Column(
//   //                     crossAxisAlignment: CrossAxisAlignment.start,
//   //                     children: [
//   //                       Text(_post!['title'],
//   //                           style: const TextStyle(
//   //                               fontSize: 24, fontWeight: FontWeight.bold)),
//   //                       const SizedBox(height: 10),
//   //                       Container(
//   //                         padding: const EdgeInsets.all(25),
//   //                         child: Center(
//   //                             child: _post!['featured_image'] != null &&
//   //                                     _post!['featured_image'].isNotEmpty
//   //                                 ? Image.network(
//   //                                     _post!['featured_image']
//   //                                                 .startsWith('http://') ||
//   //                                             _post!['featured_image']
//   //                                                 .startsWith('https://')
//   //                                         ? _post!['featured_image']
//   //                                         : 'http://192.168.1.26:8000${_post!['featured_image']}',
//   //                                   )
//   //                                 : const Icon(Icons.image, size: 50)),
//   //                       ),
//   //                       const SizedBox(height: 10),
//   //                       Text(
//   //                         _post!['text'],
//   //                         style: const TextStyle(fontSize: 16),
//   //                         textAlign: TextAlign.justify,
//   //                       ),
//   //                       const SizedBox(height: 10),
//   //                       Text('Author: ${_author[_post!['author']]}',
//   //                           style: const TextStyle(fontSize: 16)),
//   //                       const SizedBox(height: 5),
//   //                       Text('Created Date: ${_post!['created_date']}',
//   //                           style: const TextStyle(fontSize: 16)),
//   //                       const SizedBox(height: 5),
//   //                       Text('Published Date: ${_post!['published_date']}',
//   //                           style: const TextStyle(fontSize: 16)),
//   //                       const SizedBox(height: 5),
//   //                       Text('Tags: ${_getTagTitles(_post!['tags'])}',
//   //                           style: const TextStyle(fontSize: 16)),
//   //                       const SizedBox(height: 5),
//   //                       Text('Category: ${_categoryMap[_post!['category']]}',
//   //                           style: const TextStyle(fontSize: 16)),
//   //                       const SizedBox(height: 5),
//   //                       const Text('Comments:',
//   //                           style: TextStyle(fontWeight: FontWeight.bold)),
//   //                       _comments.isNotEmpty
//   //                           ? ListView.builder(
//   //                               shrinkWrap: true,
//   //                               itemCount: _comments.length,
//   //                               itemBuilder: (context, index) {
//   //                                 return CommentTile(
//   //                                   comment: _comments[index],
//   //                                   onReply: (replyText) {
//   //                                     _addReply(
//   //                                         _comments[index]['id'], replyText);
//   //                                   },
//   //                                 );
//   //                               },
//   //                             )
//   //                           : const Text('No comments yet'),
//   //                       const SizedBox(height: 20),
//   //                       TextField(
//   //                         controller: _commentController,
//   //                         decoration:
//   //                             const InputDecoration(labelText: 'Add a comment..'),
//   //                       ),
//   //                       const SizedBox(height: 10),
//   //                       ElevatedButton(
//   //                         onPressed: () async {
//   //                           if (_commentController.text.isNotEmpty) {
//   //                             await _addComment(_commentController.text);
//   //                             _commentController.clear();
//   //                           }
//   //                         },
//   //                         child: const Text('Submit'),
//   //                       ),
//   //                     ],
//   //                   ),
//   //                 )
//   //               : const Center(child: Text('Post not found')),
//   //         ));
//   //   }
//   // }


//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Post Detail')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     } else if (_hasError) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Post Detail')),
//         body: const Center(child: Text('Failed to load post details')),
//       );
//     } else {
//       return Scaffold(
//           appBar: AppBar(title: const Text('Post Detail')),
//           body: SingleChildScrollView(
//             child: _post != null
//                 ? Padding(
//                     padding: const EdgeInsets.all(22),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(_post!['title'],
//                             style: const TextStyle(
//                                 fontSize: 24, fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 10),
//                         Container(
//                           padding: const EdgeInsets.all(25),
//                           child: Center(
//                               child: _post!['featured_image'] != null &&
//                                       _post!['featured_image'].isNotEmpty
//                                   ? Image.network(
//                                       _post!['featured_image']
//                                                   .startsWith('http://') ||
//                                               _post!['featured_image']
//                                                   .startsWith('https://')
//                                           ? _post!['featured_image']
//                                           : 'http://192.168.1.26:8000${_post!['featured_image']}',
//                                     )
//                                   : const Icon(Icons.image, size: 50)),
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           _post!['text'],
//                           style: const TextStyle(fontSize: 16),
//                           textAlign: TextAlign.justify,
//                         ),
//                         const SizedBox(height: 10),
//                         Text('Author: ${_author[_post!['author']]}',
//                             style: const TextStyle(fontSize: 16)),
//                         const SizedBox(height: 5),
//                         Text('Created Date: ${_post!['created_date']}',
//                             style: const TextStyle(fontSize: 16)),
//                         const SizedBox(height: 5),
//                         Text('Published Date: ${_post!['published_date']}',
//                             style: const TextStyle(fontSize: 16)),
//                         const SizedBox(height: 5),
//                         Text('Tags: ${_getTagTitles(_post!['tags'])}',
//                             style: const TextStyle(fontSize: 16)),
//                         const SizedBox(height: 5),
//                         Text('Category: ${_categoryMap[_post!['category']]}',
//                             style: const TextStyle(fontSize: 16)),
//                         const SizedBox(height: 5),
//                         const Text('Comments:',
//                             style: TextStyle(fontWeight: FontWeight.bold)),
//                         _comments.isNotEmpty
//                             ? ListView.builder(
//                                 shrinkWrap: true,
//                                 itemCount: _comments.length,
//                                 itemBuilder: (context, index) {
//                                   return ListTile(
//                                     title: Text(_comments[index]['body']),
//                                     subtitle: Text(
//                                         'By ${_comments[index]['name']} at ${_comments[index]['created']} '),
//                                   );
//                                 },
//                               )
//                             : const Text('No comments yet'),
//                         const SizedBox(height: 20),
//                         TextField(
//                           controller: _commentController,
//                           decoration: const InputDecoration(
//                               labelText: 'Add a comment..'),
//                         ),
//                         const SizedBox(height: 10),
//                         ElevatedButton(
//                           onPressed: () async {
//                             if (_commentController.text.isNotEmpty) {
//                               await _addComment(_commentController.text);
//                               _commentController.clear();
//                             }
//                           },
//                           child: const Text('Submit'),
//                         ),
//                       ],
//                     ),
//                   )
//                 : const Center(child: Text('Post not found')),
//           ));
//     }
//   }
// }

// // class CommentTile extends StatefulWidget {
// //   final Map<String, dynamic> comment;
// //   final Function(String) onReply;

// //   const CommentTile({required this.comment, required this.onReply, super.key});

// //   @override
// //   _CommentTileState createState() => _CommentTileState();
// // }

// // class _CommentTileState extends State<CommentTile> {
// //   bool _showReplyField = false;
// //   final TextEditingController _replyController = TextEditingController();

// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         ListTile(
// //           title: Text(widget.comment['body']),
// //           subtitle: Text(
// //               'By ${widget.comment['name']} at ${widget.comment['created']} '),
// //           trailing: IconButton(
// //             icon: const Icon(Icons.reply),
// //             onPressed: () {
// //               setState(() {
// //                 _showReplyField = true;
// //               });
// //             },
// //           ),
// //         ),
// //         if (_showReplyField)
// //           Padding(
// //             padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
// //             child: Column(
// //               children: [
// //                 TextField(
// //                   controller: _replyController,
// //                   decoration: const InputDecoration(labelText: 'reply to comment...'),
// //                 ),
// //                 ElevatedButton(
// //                   onPressed: () {
// //                     if (_replyController.text.isNotEmpty) {
// //                       widget.onReply(_replyController.text);
// //                       _replyController.clear();
// //                       setState(() {
// //                         _showReplyField = false;
// //                       });
// //                     }
// //                   },
// //                   child: const Text('Submit Reply'),
// //                 ),
// //               ],
// //             ),
// //           ),

// //       ],
// //     );
// //   }
// // }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PostDetailPage extends StatefulWidget {
  final int postId;
  final String postTitle;
  const PostDetailPage(
      {super.key, required this.postId, required this.postTitle});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  bool _isLoading = false;
  bool _hasError = false;
  Map<String, dynamic>? _post;
  String token = '';
  String username = '';

  Map<int, String> _categoryMap = {};
  Map<int, String> _tagMap = {};
  Map<int, String> _author = {};
  List<dynamic> _comments = [];

  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _fetchCategories();
    _fetchTags();
    _fetchAuthorDetails();
    _fetchPostDetail();
    _fetchComments();
  }

  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    username = prefs.getString('username') ?? ''; // Retrieve the username
  }

  Future<void> _fetchPostDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    _fetchComments();
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.26:8000/posts/${widget.postId}/'),
        headers: {
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _post = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          print('Error loading post detail');
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        print('Exception occurred: $e');
      });
    }
  }

  Future<void> _fetchCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    final response = await http.get(
      Uri.parse('http://192.168.1.26:8000/category/'),
      headers: {'Authorization': 'Token $token'},
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List categories = jsonResponse['results'];
      setState(() {
        _categoryMap = {
          for (var category in categories) category['id']: category['title']
        };
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<void> _fetchTags() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    final response = await http.get(
      Uri.parse('http://192.168.1.26:8000/tags/'),
      headers: {'Authorization': 'Token $token'},
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List tags = jsonResponse['results'];
      setState(() {
        _tagMap = {for (var tag in tags) tag['id']: tag['title']};
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load tags');
    }
  }

  String _getTagTitles(List<dynamic> tagIds) {
    List<String> tagTitles = tagIds.map((id) {
      return _tagMap[id] ?? '';
    }).toList();
    return tagTitles.join(', ');
  }

  Future<void> _fetchAuthorDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    final response = await http.get(
      Uri.parse('http://192.168.1.26:8000/user/'),
      headers: {'Authorization': 'Token $token'},
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List users = jsonResponse['results'];
      setState(() {
        _author = {for (var user in users) user['id']: user['username']};
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load author');
    }
  }

  Future<void> _fetchComments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    setState(() {
      _isLoading = true;
    });
    final response = await http.get(
      Uri.parse('http://192.168.1.26:8000/comments/'),
      headers: {'Authorization': 'Token $token'},
    );
    if (response.statusCode == 200) {
      List<dynamic> allComments = json.decode(response.body)['results'];

      List<dynamic> postComments = allComments
          .where((comment) => comment['post']['title'] == widget.postTitle)
          .toList();

      setState(() {
        _comments = postComments;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load comments');
    }
  }

  Future<void> _addComment(String commentText) async {
    setState(() {
      _isLoading = true;
    });
    final response = await http.post(
      Uri.parse('http://192.168.1.26:8000/comments/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'body': commentText,
        'post_id': widget.postId,
        // 'name': prefs.getString('username'),
        'name': username,
      }),
    );
    if (response.statusCode == 201) {
      setState(() {
        _isLoading = false;
      });
      _fetchComments();
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to add comment');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post Detail')),
        body: const Center(child: CircularProgressIndicator()),
      );
    } else if (_hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post Detail')),
        body: const Center(child: Text('Failed to load post details')),
      );
    } else {
      return Scaffold(
          appBar: AppBar(title: const Text('Post Detail')),
          body: SingleChildScrollView(
            child: _post != null
                ? Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_post!['title'],
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(25),
                          child: Center(
                              child: _post!['featured_image'] != null &&
                                      _post!['featured_image'].isNotEmpty
                                  ? Image.network(
                                      _post!['featured_image']
                                                  .startsWith('http://') ||
                                              _post!['featured_image']
                                                  .startsWith('https://')
                                          ? _post!['featured_image']
                                          : 'http://192.168.1.26:8000${_post!['featured_image']}',
                                    )
                                  : const Icon(Icons.image, size: 50)),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _post!['text'],
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 10),
                        Text('Author: ${_author[_post!['author']]}',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 5),
                        Text('Created Date: ${_post!['created_date']}',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 5),
                        Text('Published Date: ${_post!['published_date']}',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 5),
                        Text('Tags: ${_getTagTitles(_post!['tags'])}',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 5),
                        Text('Category: ${_categoryMap[_post!['category']]}',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 5),
                        const Text('Comments:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        _comments.isNotEmpty
                            ? ListView.builder(
                                shrinkWrap: true,
                                itemCount: _comments.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(_comments[index]['body']),
                                    subtitle: Text(
                                        'By ${_comments[index]['name']} at ${_comments[index]['created']} '),
                                  );
                                },
                              )
                            : const Text('No comments yet'),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                              labelText: 'Add a comment..'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            if (_commentController.text.isNotEmpty) {
                              await _addComment(_commentController.text);
                              _commentController.clear();
                            }
                          },
                          child: const Text('Submit'),
                        ),
                      ],
                    ),
                  )
                : const Center(child: Text('Post not found')),
          ));
    }
  }
}