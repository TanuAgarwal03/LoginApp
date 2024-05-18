import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PostDetailPage extends StatefulWidget {
  final int postId;
  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  bool _isLoading = false;
  bool _hasError = false;
  Map<String, dynamic>? _post;
  String token = '';

  @override
  void initState() {
    super.initState();
    _fetchPostDetail();
  }

  Future<void> _fetchPostDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
  try{
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
    

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post Detail')),
        body: const Center(
          child: CircularProgressIndicator()
          ),
      );
    } else if (_hasError) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Post Detail')
          ),
        body: const Center(
          child: Text('Failed to load post details')
          ),
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
                    Text(_post!['title'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(25),
                      child:  Center(child: _post!['featured_image'] != null && _post!['featured_image'].isNotEmpty
                        ? Image.network(
                            _post!['featured_image'].startsWith('http://') || _post!['featured_image'].startsWith('https://')
                                ? _post!['featured_image']
                                : 'http://192.168.1.26:8000${_post!['featured_image']}',
                          )
                        : const Icon(Icons.image, size: 50)),
                    ),
                    const SizedBox(height: 10),
                    Text(_post!['text'], style: const TextStyle(fontSize: 16) , textAlign: TextAlign.justify,),
                    const SizedBox(height: 10),
                    Text('Author: ${_post!['author']}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 5),
                    Text('Created Date: ${_post!['created_date']}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 5),
                    Text('Published Date: ${_post!['published_date']}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 5),
                    Text('Tags: ${_post!['tags']}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 5),
                    Text('Category: ${_post!['category']}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 5),
                  ],

                ),
              )
            : const Center(child: Text('Post not found')),) 
      );
    }
  }
}