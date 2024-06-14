// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/painting.dart';
// import 'package:flutter/widgets.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PostDetailPage extends StatefulWidget {
  final String slug;
  final String postTitle;
  const PostDetailPage(
      {super.key, required this.slug, required this.postTitle});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  bool _isLoading = false;
  bool _hasError = false;
  Map<String, dynamic>? _post;
  String token = '';
  String username = '';
  String email = '';
  int mobile = 0;
  int userId = 0;
  String htmlcode = '';
  String postTitle = '';
  String imageUrl = '';

  Map<int, String> _categoryMap = {};
  Map<int, String> _tagMap = {};
  List<dynamic> _comments = [];
  final TextEditingController _commentController = TextEditingController();
  // Map<int, TextEditingController> _replyControllers = {};

  // Map<int , bool> _expandedComments = {};
  int? parentId;
  bool _isReplyMode = false;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _fetchCategories();
    _fetchTags();
    _fetchPostDetail();
    _fetchComments();
  }

  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    username = prefs.getString('username') ?? '';
    email = prefs.getString('email') ?? '';
    mobile = prefs.getInt('mobile') ?? 0;
    userId = prefs.getInt('id') ?? 0;
    imageUrl = prefs.getString('image') ?? '';
  }

  Future<void> _fetchPostDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final response = await http.get(
        Uri.parse(
            'https://test.securitytroops.in/stapi/v1/blogs/posts/${widget.slug}/'),
        headers: {
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _post = json.decode(response.body);
          htmlcode = _post!['content'];
          postTitle = _post!['title'].replaceAll(RegExp(r'[^\w\s]+'), '');
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        print('Failed to load post details: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      print('Error loading post details: $e');
    }
  }

  Future<void> _fetchCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    final response = await http.get(
      Uri.parse('https://test.securitytroops.in/stapi/v1/blogs/categories/'),
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
      Uri.parse('https://test.securitytroops.in/stapi/v1/blogs/tags/'),
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

  Future<void> _fetchComments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://test.securitytroops.in/stapi/v1/blogs/posts/${widget.slug}/'),
        headers: {
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _comments = json.decode(response.body)['comments'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        print('Failed to load comments: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      print('Error loading comments: $e');
    }
  }

  Future<void> _addComment(String comment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    int postId = _post!['id'];

    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> requestBody = {
      'post': postId,
      'content': comment,
      'email': email,
      'mobile': mobile,
      'name': username,
      'user': userId,
    };

    if (parentId != null) {
      requestBody['parent'] = parentId;
      _isReplyMode = true;
    }

    try {
      final response = await http.post(
        Uri.parse('https://test.securitytroops.in/stapi/v1/blogs/comment/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        _fetchComments();
        _commentController.clear();
        parentId = null;
        setState(() {
          _isLoading = false;
          _isReplyMode = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('Failed to add comment: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error adding comment: $e');
    }
  }

   String _formatDate(String dateString) {
    final dateTime = DateTime.parse(dateString);
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
            title: const Text('Post Detail',
                style: TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
            backgroundColor: Colors.blue),
        body: const Center(child: CircularProgressIndicator()),
      );
    } else if (_hasError) {
      return Scaffold(
        appBar: AppBar(
          title:
              const Text('Post Detail', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          backgroundColor: Colors.blue,
        ),
        body: const Center(child: Text('Failed to load post details')),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title:
              const Text('Post Detail', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          backgroundColor: Colors.blue,
        ),
        body: SingleChildScrollView(
          child: _post != null
              ? Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        postTitle,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),

                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Image.network(
                          _post!['featured'].startsWith('http://') ||
                                  _post!['featured'].startsWith('https://')
                              ? _post!['featured']
                              : 'https://test.securitytroops.in/stapi/v1/blogs/posts/${_post!['featured']}',
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(height: 10),
                      Padding(padding: const EdgeInsets.fromLTRB(20.0 , 0.0, 20.0, 0.0),
                      child :ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            minimumSize: const Size(10.0, 40.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.0),
                            )),
                        onPressed: () {
                          showModalBottomSheet(
                              backgroundColor: Colors.grey.shade100,
                              showDragHandle: true,
                              enableDrag: true,
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                    builder: (BuildContext builder, StateSetter setState) {
                                  return Container(
                                    height: MediaQuery.of(context).size.height *0.8,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(0.0),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                _comments.isNotEmpty
                                                    ? Column(
                                                        children: _comments.map((comment) {
                                                          bool showAllReplies =false;
                                                          return StatefulBuilder(
                                                            builder: (context,replyState) {
                                                              return Column(
                                                                crossAxisAlignment:CrossAxisAlignment.start,
                                                                mainAxisAlignment:MainAxisAlignment.start,
                                                                children: [
                                                                  Column(
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          ClipOval(
                                                                              child: Image.network(imageUrl, height: 30, width: 30 , 
                                                                              errorBuilder: (BuildContext context, Object exception,StackTrace? stackTrace) {
                                                                                            return const Icon(Icons.account_circle_rounded);
                                                                                          },)),
                                                                          const SizedBox(
                                                                              width: 8.0),
                                                                          Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                '${comment['users']['username']}',
                                                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                                              ),
                                                                              Text(comment['content'], style: const TextStyle(fontSize: 16, color: Colors.black)),
                                                                              TextButton(
                                                                                onPressed: () {
                                                                                  replyState(() {
                                                                                    parentId = comment['id'];
                                                                                    _isReplyMode = true;
                                                                                  });
                                                                                  print(parentId);
                                                                                },
                                                                                child: Text('Reply', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 12)),
                                                                              ),
                                                                            ],
                                                                          )
                                                                        ],
                                                                      ),
                                                                      Column(
                                                                        children: comment['replies']
                                                                            .take(showAllReplies
                                                                                ? comment['replies'].length
                                                                                : 1)
                                                                            .map<Widget>((reply) {
                                                                          return Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 20.0),
                                                                            child:
                                                                                ListTile(
                                                                              leading: ClipOval(
                                                                                child: Image.network(
                                                                                  imageUrl,
                                                                                  height: 30,
                                                                                  width: 30,
                                                                                  errorBuilder: (BuildContext context , Object exception , StackTrace? stackTrace) {
                                                                                    return const Icon(Icons.account_circle_rounded);
                                                                                  },
                                                                                ),
                                                                              ),
                                                                              title: Text(
                                                                                '${reply['users']['username']}',
                                                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                                              ),
                                                                              subtitle: Text(
                                                                                reply['content'],
                                                                                style: const TextStyle(fontSize: 16, color: Colors.black),
                                                                              ),
                                                                            ),
                                                                          );
                                                                        }).toList(),
                                                                      ),
                                                                      if (comment['replies']
                                                                              .length >
                                                                          1)
                                                                        TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              replyState(() {
                                                                                showAllReplies = !showAllReplies;
                                                                              });
                                                                            },
                                                                            child:
                                                                                Align(
                                                                              alignment: Alignment.centerLeft,
                                                                              child: Text(
                                                                                showAllReplies ? 'Hide' : 'Show all replies (${comment['replies'].length})',
                                                                                style: TextStyle(
                                                                                  color: Colors.grey[700],
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontSize: 14,
                                                                                ),
                                                                              ),
                                                                            )),
                                                                    ],
                                                                  ),
                                                                  const Divider(),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        }).toList(),
                                                      )
                                                    : const Text(
                                                        'No comments yet.'),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.80,
                                                  child: TextFormField(
                                                    controller:
                                                        _commentController,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      hintText: parentId == null
                                                          ? 'Add a new comment'
                                                          : 'Reply to comment',
                                                      suffixIcon: _isReplyMode
                                                          ? IconButton(
                                                              icon: const Icon(Icons
                                                                  .cancel_sharp),
                                                              onPressed: () {
                                                                setState(() {
                                                                  parentId =null;
                                                                  _isReplyMode =false;
                                                                });
                                                                print(parentId);
                                                              },
                                                            )
                                                          : null,
                                                      border: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20.0)),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20.0),
                                                        borderSide:
                                                            const BorderSide(
                                                                color: Colors
                                                                    .black),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10.0),
                                                IconButton.filled(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 10.0),
                                                    onPressed: () {
                                                      _addComment(
                                                          _commentController
                                                              .text);
                                                    },
                                                    icon:
                                                        const Icon(Icons.send))
                                              ],
                                            )
                                            ),
                                      ],
                                    ),
                                  );
                                });
                              });
                        },
                        child: const Text('Comment',
                            style: TextStyle(color: Colors.white)),
                      ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: HtmlWidget(
                          htmlcode,
                          textStyle: const TextStyle(fontSize: 16 ),
                        ),
                      ),
                      Padding(padding: const EdgeInsets.fromLTRB(20.0 , 5.0 , 20.0 , 0.0), 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Author: ${_post!['authors']['display']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Created Date: ${_formatDate(_post!['timestamp'])}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Published Date: ${_formatDate(_post!['utimestamp'])}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Tags: ${_getTagTitles(_post!['tag'])}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Category: ${_categoryMap[_post!['category']]}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      )
                    ],
                  ),
                )
              : const Center(child: Text('Post not found')),
        ),
      );
    }
  }
}
