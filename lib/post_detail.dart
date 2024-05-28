import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class PostDetailPage extends StatefulWidget {
  final String slug;
  final String postTitle;
  const PostDetailPage(
      {super.key, required this.slug, required this.postTitle });


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

  Map<int, String> _categoryMap = {};
  Map<int, String> _tagMap = {};
  Map<int, String> _author = {};
  List<dynamic> _comments = [];
  final TextEditingController _commentController = TextEditingController();
  Map<int, TextEditingController> _replyControllers = {};

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
    username = prefs.getString('username') ?? ''; 
    email = prefs.getString('email') ?? '';
    mobile = prefs.getInt('mobile') ?? 0;
    userId = prefs.getInt('id') ?? 0;
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
        Uri.parse('http://3.110.219.27:8005/stapi/v1/blogs/posts/${widget.slug}/'),
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
      Uri.parse('http://3.110.219.27:8005/stapi/v1/blogs/categories/'),
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
      Uri.parse('http://3.110.219.27:8005/stapi/v1/blogs/tags/'),
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
      Uri.parse('http://3.110.219.27:8005/stapi/v1/users/'),
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
      throw Exception('Failed to load authors');
    }
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
        Uri.parse('http://3.110.219.27:8005/stapi/v1/blogs/posts/${widget.slug}/'),
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
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _addComment(String comment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    int postId = _post!['id'];

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://3.110.219.27:8005/stapi/v1/blogs/comment/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'post': postId,
          'content': comment,
          'email' : email,
          'mobile' : mobile,
          'name' : username,
          'user' : userId,
        }),
      );

      if (response.statusCode == 201) {
        _fetchComments();
        _commentController.clear();
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          print('Failed to post comment');
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        print('Exception occurred: $e');
      });
    }
  }
 Future<void> _addReply(int commentId, String reply) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    int postId = _post!['id'];

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://3.110.219.27:8005/stapi/v1/blogs/comment/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'parent': commentId,
          'content': reply,
          'email': email,
          'mobile': mobile,
          'name': username,
          'user': userId,
          'post' :postId,
        }),
      );

      if (response.statusCode == 201) {
        _fetchComments();
        _replyControllers[commentId]?.clear();
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          print('Failed to post reply');
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        print('Exception occurred: $e');
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post Detail')),
        body: const Center(child: Text('unavailable')),
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
                      
                      Text(postTitle,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 30),
                      Image.network(_post!['featured'].startsWith('http://') ||
                                      _post!['featured'].startsWith('https://')
                                  ? _post!['featured']
                                  : 'http://3.110.219.27:8005/stapi/v1/blogs/posts/${_post!['featured']}',
                              width: 400,
                              height: 250,
                              fit: BoxFit.cover),

                      
                      const SizedBox(height: 40),

                      HtmlWidget(
                        htmlcode,                             
                      ),

                      const SizedBox(height: 10),
                      Text('Author: ${_author[_post!['author']]}',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 5),
                      Text('Created Date: ${_post!['timestamp']}',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 5),
                      Text('Published Date: ${_post!['utimestamp']}',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 5),
                      Text('Tags: ${_getTagTitles(_post!['tag'])}',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 5),
                      Text('Category: ${_categoryMap[_post!['category']]}',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 20),
                      const Text(
                        'Comments:',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _comments.isNotEmpty
                          ? Column(
                              children: _comments
                              .map((comment) => Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ListTile(
                                            title: Text(comment['content']),
                                            subtitle: Text('By: ${comment['users']['username']}'),
                                          ),
                                          const SizedBox(height: 10),
                                          Column(
                                            children: (comment['replies'] as List)
                                                .map((reply) => ListTile(
                                                      title: Text(reply['content']),
                                                      subtitle: Text('By: ${reply['users']['username']}'),
                                                    ))
                                                .toList(),
                                          ),
                                          TextField(
                                            controller: _replyControllers[comment['id']] ??= TextEditingController(),
                                            decoration: const InputDecoration(
                                              hintText: 'Add a reply...',
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: () {
                                              _addReply(comment['id'], _replyControllers[comment['id']]!.text);
                                            },
                                            child: const Text('Reply'),
                                          ),
                                          const SizedBox(height: 20),
                                        ],
                                      ))
                                  .toList(),
                            )
                          : const Text('No comments yet.'),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(                  
                          ),
                        
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          _addComment(_commentController.text);
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                )
              : const Center(child: Text('Post not found')),
        ),
      );
    }
  }
}
