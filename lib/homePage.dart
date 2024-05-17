import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class BlogPostsPage extends StatefulWidget {
  const BlogPostsPage({super.key});

  @override
  State<BlogPostsPage> createState() => _BlogPostsPageState();
}

class _BlogPostsPageState extends State<BlogPostsPage> {
  List<dynamic> _posts = [];
  // Map<String , dynamic> _posts = {};
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
    });
    final response = await http.get(Uri.parse('http://192.168.1.26:8000/posts/'),
    headers: {
      'Authorization' : 'token $token',
    },
    );
    
    
    if (response.statusCode == 200) {
      setState(() {
        _posts = json.decode(response.body)['results'];
        _isLoading = false;
      });
      print(_posts);
    } else {
      setState(() {
        _isLoading = false;
        // _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (_isLoading) {
    //   return Scaffold(
    //     appBar: AppBar(title: const Text('Blog Posts')),
    //     body: const Center(child: CircularProgressIndicator()),
    //   );
    // } 
    // else if (_hasError) {
    //   return Scaffold(
    //     appBar: AppBar(title: const Text('Blog Posts')),
    //     body: const Center(child: Text('Failed to load posts')),
    //   );
    // } 
    
      return Scaffold(
          appBar: AppBar(title: const Text('Blog Posts')),
          // body: Container(constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height*0.9 , maxWidth: MediaQuery.of(context).size.width*0.9),
          //   child: ListView.builder(itemBuilder: ((context, index) {
          //     final post = _posts[index];
          //     print('posts');
          //     return Text("${post['title']}");
          //   })),
          // )
          body: Container(
            child: Text("this"),
          )
          );
  }
}
