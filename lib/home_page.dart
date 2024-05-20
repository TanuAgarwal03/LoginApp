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
      Uri.parse('http://192.168.1.26:8000/posts/'),
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
                    return ListTile(
                      leading: post['thumbnails'] != null && post['thumbnails'].isNotEmpty
                          ? Image.network(
                              post['thumbnails'].startsWith('http://') ||
                                      post['thumbnails'].startsWith('https://')
                                  ? post['thumbnails']
                                  : 'http://192.168.1.26:8000${post['thumbnails']}',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image, size: 50),
                      title: Text(post['title']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailPage(postId: post['id'] , postTitle: post['title'],),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
