import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import 'package:login_page/apiService.dart';
import 'package:login_page/post_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
// import 'package:translator/translator.dart';

class BlogPostsPage extends StatefulWidget {
  const BlogPostsPage({super.key});

  @override
  State<BlogPostsPage> createState() => _BlogPostsPageState();
}

class _BlogPostsPageState extends State<BlogPostsPage> {
  // GoogleTranslator translator = GoogleTranslator();
  List<dynamic> _posts = [];
  bool _isLoading = false;
  bool _hasError = false;
  String token = '';
  int userId = 0 ;
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _getUserId();
    _fetchPosts();
  }

  Future<void> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('id') ?? 0;
  }

  // Future<void> _fetchPosts() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   token = prefs.getString('token') ?? '';
  //   setState(() {
  //     _isLoading = true;
  //     _hasError = false;
  //   });

  //   final response = await http.get(
  //     Uri.parse('https://test.securitytroops.in/stapi/v1/blogs/posts/'),
  //     headers: {
  //       'Authorization': 'Token $token',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     setState(() {
  //       _posts = json.decode(response.body)['results'];
  //       _isLoading = false;
  //     });
  //   } else {
  //     setState(() {
  //       _isLoading = false;
  //       _hasError = true;
  //     });
  //   }
  // }
  Future<void> _fetchPosts() async {
  try {
    final response = await apiService.getAPI('blogs/posts/');
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
  } catch (e) {
    setState(() {
      _isLoading = false;
      _hasError = true;
    });
  }
}


  void _updateLikeStatus(int postId, bool likeStatus, bool userExists) {
    setState(() {
      var post = _posts.firstWhere((post) => post['id'] == postId);
      likeStatus ? post['likes']++ : post['likes']--;

      if (userExists) {
        for (var action in post['actions']) {
          if (action['user'] == userId) {
            action['like'] = likeStatus;
            break;
          }
        }
      } else {
        post['actions'].add({
          'user': userId,
          'like': likeStatus,
        });
      }
    });
  }

  Future<void> _toggleLike(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    userId = prefs.getInt('id') ?? 0;

    try {
      bool userExists = false;
      bool likeStatus = false;
      String? actionId;
      var post = _posts[index];

      for (var action in post['actions']) {
        if (action['user'] == userId) {
          userExists = true;
          likeStatus = action['like'];
          actionId = action['id'].toString();
          break;
        }
      }
      likeStatus = !likeStatus;
      setState(() {
        _getUserId();
        likeStatus ? post['likes']++ : post['likes']--;

        if (userExists) {
          for (var action in post['actions']) {
            if (action['user'] == userId) {
              action['like'] = likeStatus;
              break;
            }
          }
        } else {
          _getUserId();
          print(userId);
          post['actions'].add({
            'id': actionId,
            'user': userId,
            'like': likeStatus,
          });
        }
      });
      final payload = {
        'like': likeStatus,
        'post': post['id'],
        'user': userId,
      };
      final requestType = userExists ? 'patch' : 'post';
      final url = userExists
          ? 'blogs/action/$actionId/'
          : 'blogs/action/';

      final response = await (requestType == 'patch'
          // ? http.patch(Uri.parse(url),
          //     headers: {
          //       'Authorization': 'Token $token',
          //       'Content-type': 'application/json',
          //     },
          //     body: json.encode(payload))
          // : http.post(Uri.parse(url),
          //     headers: {
          //       'Authorization': 'Token $token',
          //       'Content-type': 'application/json',
          //     },
          //     body: json.encode(payload))
          ? apiService.patchAPI(url, payload , headers: {
            'Authorization' : 'Token $token',
            'Content-Type' : 'application/json'
          })
          : apiService.postAPI(url, payload , headers: {
            'Authorization' : 'Token $token',
            'Content-Type' : 'application/json'
          })
      );

      if (response.statusCode != 200) {
        setState(() {
          likeStatus ? post['likes']-- : post['likes']++;
          if (userExists) {
            for (var action in post['actions']) {
              if (action['user'] == userId) {
                action['like'] = !likeStatus;
                break;
              }
            }
          } else {
            post['actions'].removeLast();
          }
        });
        print(userId);
        print('Failed to toggle like: ${response.statusCode}');
      }

    } catch (e) {
      print('Error toggling like: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String formatTimestamp(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    return DateFormat('MMM dd, yyyy ').format(dateTime);
  }

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
                    String postTitle = post['title'].replaceAll(RegExp(r'[^\w\s]+'), '');
                    String postTime = formatTimestamp(post['timestamp']);
                    bool userExists = post['actions'].any((action) => action['user'] == userId);
                    bool likeStatus = userExists && post['actions'].firstWhere((action) => action['user'] == userId)['like'];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: [
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
                                      onLikeToggle: (postId, likeStatus, userExists) => _updateLikeStatus(postId, likeStatus, userExists),
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  if (post['thumbnail'] != null && post['thumbnail'].isNotEmpty)
                                    Image.network(
                                      post['thumbnail'].startsWith('http://') || post['thumbnail'].startsWith('https://')
                                          ? post['thumbnail']
                                          : 'https://test.securitytroops.in/stapi/v1/blogs/posts/${post['thumbnail']}',
                                      height: 140,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          postTitle,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Divider(),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                              onPressed: () => _toggleLike(index),
                                              icon: Icon(
                                                likeStatus ? Icons.thumb_up : Icons.thumb_up_alt_outlined,color: Colors.blue,
                                              ),
                                            ),
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
