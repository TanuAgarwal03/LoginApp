import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/post_detail.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BlogPostsPage extends StatefulWidget {
  const BlogPostsPage({super.key});

  @override
  State<BlogPostsPage> createState() => _BlogPostsPageState();
}

class _BlogPostsPageState extends State<BlogPostsPage> {
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

                    return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Card.outlined(
                            elevation: 15,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
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
                                      height: 160,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        15, 15, 15, 2),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          postTitle,
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        const Divider(),
                                      ],

                                    ),
                                  ),
                                  Container(height: 15),
                                ],
                              ),
                            )));
                  },
                ),
    );
  }
}
