import 'package:flutter/material.dart';
// import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as dom;

class PostDetailPage extends StatefulWidget {
  final String slug;
  final String postTitle;
  const PostDetailPage(
      {super.key, required this.slug, required this.postTitle});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  GoogleTranslator translator = GoogleTranslator();
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
  int? parentId;
  bool _isReplyMode = false;
  String translatedPostTitle = '';
  String parsedData = '';
  String translatedPostContent = '';
  String translatedPostAuthor = '';
  String translatedPostCDate = '';
  String translatedPostPDate = '';
  String translatedTags = '';
  String translatedCategory = '';
  String text = 'Comment';
  String translatedButton = '';
  String translatedReplyTextButton = '';
  String translatedHideReplies = '';
  String translatedShowReplies = '';
  String translatedNewComment = '';
  String translatedReplyComment = '';
  List<Map<String, dynamic>> translatedCommentsList = [];
  bool isTranslated = false;

  bool _isTranslating = false;
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
        _post = json.decode(response.body);
        postTitle = _post!['title'].replaceAll(RegExp(r'[^\w\s]+'), '');
        dom.Document document = htmlParser.parse(_post!['content']);
        parsedData = parseDocument(document);
        setState(() {
          _translateData("en");
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

  String parseDocument(dom.Document document) {
    List<String> elementsText = document.body!.children.map((element) {
      return element.text;
    }).toList();
    String parsedData = elementsText.join('\n');
    return parsedData;
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
      Uri.parse('https://test.securitytroops.in/stapi/v1/blogs/posts/${widget.slug}/'),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> comments = json.decode(response.body)['comments'];

      if (isTranslated) {
        final translator = GoogleTranslator();
        for (var comment in comments) {
          var translatedComment = await translator.translate(comment['content'], to: 'hi');
          comment['content'] = translatedComment.text;

          for (var reply in comment['replies']) {
            var translatedReply = await translator.translate(reply['content'], to: 'hi');
            reply['content'] = translatedReply.text;
          }
        }
      }

      setState(() {
        _comments = comments;
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

  try {
    if (isTranslated) {
      // var translatedComment = await translator.translate(comment, to: );
      // comment = translatedComment.text;
    }

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


  Future<void> _translateData(String languageCode) async {
    setState(() {
      _isTranslating = true;
    });
  try {
    final List<Future> futures = [];
    // Translate static content
    final titleFuture = translator.translate(postTitle, to: languageCode).then((value) => value.text);
    final contentFuture = translator.translate(parsedData, to: languageCode).then((value) => value.text);
    final authorFuture = translator.translate('Author: ${_post!['authors']['display']}', to: languageCode).then((value) => value.text);
    final createdDateFuture = translator.translate('Created Date: ${_formatDate(_post!['timestamp'])}', to: languageCode).then((value) => value.text);
    final publishedDateFuture = translator.translate('Published Date: ${_formatDate(_post!['utimestamp'])}', to: languageCode).then((value) => value.text);
    final tagsFuture = translator.translate('Tags: ${_getTagTitles(_post!['tag'])}', to: languageCode).then((value) => value.text);
    final categoryFuture = translator.translate('Category: ${_categoryMap[_post!['category']]}', to: languageCode).then((value) => value.text);
    final commentButtonFuture = translator.translate(text, to: languageCode).then((value) => value.text);
    final replyTextButtonFuture = translator.translate('Reply', to: languageCode).then((value) => value.text);
    final hideRepliesFuture = translator.translate('Hide', to: languageCode).then((value) => value.text);
    final showRepliesFuture = translator.translate('Show all replies', to: languageCode).then((value) => value.text);
    final newCommentFuture = translator.translate('Add a new comment', to: languageCode).then((value) => value.text);
    final replyCommentFuture = translator.translate('Reply to comment', to: languageCode).then((value) => value.text);

    futures.addAll([
      titleFuture,
      contentFuture,
      authorFuture,
      createdDateFuture,
      publishedDateFuture,
      tagsFuture,
      categoryFuture,
      commentButtonFuture,
      replyTextButtonFuture,
      hideRepliesFuture,
      showRepliesFuture,
      newCommentFuture,
      replyCommentFuture,
    ]);

    final List<Map<String, dynamic>> translatedComments = [];
    for (var comment in _comments) {
      final usernameFuture = translator.translate(comment['users']['username'], to: languageCode).then((value) => value.text);
      final contentFuture = translator.translate(comment['content'], to: languageCode).then((value) => value.text);

      final List<Future<Map<String, dynamic>>> replyFutures = [];
      for (var reply in comment['replies']) {
        final translatedReplyUsernameFuture = translator.translate(reply['users']['username'], to: languageCode).then((value) => value.text);
        final translatedReplyContentFuture = translator.translate(reply['content'], to: languageCode).then((value) => value.text);

        replyFutures.add(Future.wait([
          translatedReplyUsernameFuture,
          translatedReplyContentFuture,
        ]).then((translatedValues) => ({
          'users': {'username': translatedValues[0]},
          'content': translatedValues[1],
        })));
      }

      final translatedReplies = await Future.wait(replyFutures);
      final translatedUsername = await usernameFuture;
      final translatedContent = await contentFuture;

      translatedComments.add({
        'id': comment['id'],
        'users': {'username': translatedUsername},
        'content': translatedContent,
        'replies': translatedReplies,
      });
    }

    // Wait for all translations to complete
    final List<dynamic> translations = await Future.wait(futures);
    setState(() {
      isTranslated = true;
      translatedPostTitle = translations[0];
      translatedPostContent = translations[1];
      translatedPostAuthor = translations[2];
      translatedPostCDate = translations[3];
      translatedPostPDate = translations[4];
      translatedTags = translations[5];
      translatedCategory = translations[6];
      translatedButton = translations[7];
      translatedReplyTextButton = translations[8];
      translatedHideReplies = translations[9];
      translatedShowReplies = translations[10];
      translatedNewComment = translations[11];
      translatedReplyComment = translations[12];
      translatedCommentsList = translatedComments;
      
    });
  } catch (e) {
    print('Error translating data: $e');
  }finally {
    setState(() {
      _isTranslating = false;
    });
  }
}

  void _reverseTranslation() {
    setState(() {
      isTranslated = false;
    });
  }

  void _selectLanguage(String language) {
    if (language == 'English') {
      setState(() {
        _reverseTranslation();
        // _translateData("en");
        isTranslated==false;
      });
      
    } else if (language == 'Hindi') {
      setState(() {
         _translateData("hi");
          isTranslated == true;
      });
    }
    else if (language == 'Gujrati') {
      setState(() {
         _translateData("gu");
          isTranslated == true;
      });
    }
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
            actions:<Widget>[
          PopupMenuButton<String>(
            onSelected: (String result) {
              _selectLanguage(result);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: '',
                enabled: false,
                child: Text(
                  'Select Language',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'English',
                child: Text('English'),
              ),
              const PopupMenuItem<String>(
                value: 'Hindi',
                child: Text('Hindi'),
              ),
              const PopupMenuItem<String>(
                value: 'Gujrati',
                child: Text('Gujrati'),
              ),
            ],
            icon: const Icon(Icons.language_outlined),
            tooltip: 'Change Language',
          ),
        ],
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
          actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String result) {
              _selectLanguage(result);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: '',
                enabled: false,
                child: Text(
                  'Select Language',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'English',
                child: Text('English'),
              ),
              const PopupMenuItem<String>(
                value: 'Hindi',
                child: Text('Hindi'),
              ),
              const PopupMenuItem<String>(
                value: 'Gujrati',
                child: Text('Gujrati'),
              ),
            ],
            icon: const Icon(Icons.language_outlined),
            tooltip: 'Change Language',
          ),
        ],
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
          actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String result) {
              _selectLanguage(result);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: '',
                enabled: false,
                child: Text(
                  'Select Language',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'English',
                child: Text('English'),
              ),
              const PopupMenuItem<String>(
                value: 'Hindi',
                child: Text('Hindi'),
              ),
              const PopupMenuItem<String>(
                value: 'Gujrati',
                child: Text('Gujrati'),
              ),
            ],
            icon: const Icon(Icons.language_outlined),
            tooltip: 'Change Language',
          ),
        ],
          backgroundColor: Colors.blue,
        ),
        body:_isTranslating
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : 
        SingleChildScrollView(
          child: _post != null
              ? Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTranslated ? translatedPostTitle : postTitle,
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
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                        child: ElevatedButton(
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
                                  return StatefulBuilder(builder:
                                      (BuildContext builder,
                                          StateSetter setState) {
                                    return Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.8,
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
                                                  isTranslated
                                                  ? translatedCommentsList.isNotEmpty
                                                      ? Column(
                                                          children: translatedCommentsList.map((comment) {
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
                                                                                child: Image.network(
                                                                              imageUrl,
                                                                              height: 30,
                                                                              width: 30,
                                                                              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                                                return const Icon(Icons.account_circle_rounded);
                                                                              },
                                                                            )),
                                                                            const SizedBox(width: 8.0),
                                                                            Flexible(
                                                                            child :Column(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    comment['users']['username'],
                                                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                                                  ),
                                                                                  Text(comment['content'], style: const TextStyle(fontSize: 16, color: Colors.black),
                                                                                      overflow: TextOverflow.ellipsis ,
                                                                                      maxLines:4
                                                                                    ),                                                                                  
                                                                                
                                                                                  TextButton(
                                                                                    onPressed: () {
                                                                                      setState(() {
                                                                                        parentId = comment['id'];
                                                                                        _isReplyMode = true;
                                                                                      });
                                                                                      print(parentId);
                                                                                    },
                                                                                    child: Text( isTranslated 
                                                                                      ?translatedReplyTextButton
                                                                                      : 'Reply',
                                                                                      style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 12)),
                                                                                  ),
                                                                                ],
                                                                              ),   
                                                                            )                                                                       
                                                                          ],
                                                                        ),
                                                                        Column(
                                                                          children: comment['replies'].take(showAllReplies ? comment['replies'].length : 1).map<Widget>((reply) {

                                                                            return Padding(
                                                                              padding: const EdgeInsets.only(left: 20.0),
                                                                              child: ListTile(
                                                                                leading: ClipOval(
                                                                                  child: Image.network(
                                                                                    imageUrl,
                                                                                    height: 30,
                                                                                    width: 30,
                                                                                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
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
                                                                        if (comment['replies'].length >1)
                                                                          TextButton(
                                                                              onPressed: () {
                                                                                replyState(() {
                                                                                  showAllReplies = !showAllReplies;
                                                                                });
                                                                              },
                                                                              child: Align(
                                                                                alignment: Alignment.centerLeft,
                                                                                child: Text(                                                                                  
                                                                                  isTranslated
                                                                                    ? showAllReplies
                                                                                        ? translatedHideReplies
                                                                                        : translatedShowReplies
                                                                                    : showAllReplies
                                                                                        ? 'Hide'
                                                                                        : 'Show all replies (${comment['replies'].length})',
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
                                                          'No comments yet.')
                                                    : _comments.isNotEmpty
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
                                                                                child: Image.network(
                                                                              imageUrl,
                                                                              height: 30,
                                                                              width: 30,
                                                                              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                                                return const Icon(Icons.account_circle_rounded);
                                                                              },
                                                                            )),
                                                                            const SizedBox(width: 8.0),
                                                                            Flexible(
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    comment['users']['username'],
                                                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                                                  ),
                                                                                  Text(comment['content'], style: const TextStyle(fontSize: 16, color: Colors.black),
                                                                                        overflow: TextOverflow.ellipsis ,
                                                                                        maxLines:4
                                                                                      ),
                                                                                  TextButton(
                                                                                    onPressed: () {
                                                                                      setState(() {
                                                                                        parentId = comment['id'];
                                                                                        _isReplyMode = true;
                                                                                      });
                                                                                      print(parentId);
                                                                                    },
                                                                                    child: Text( isTranslated 
                                                                                      ?translatedReplyTextButton
                                                                                      : 'Reply',
                                                                                      style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 12)),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                        Column(
                                                                          children: comment['replies'].take(showAllReplies ? comment['replies'].length : 1).map<Widget>((reply) {

                                                                            return Padding(
                                                                              padding: const EdgeInsets.only(left: 20.0),
                                                                              child: ListTile(
                                                                                leading: ClipOval(
                                                                                  child: Image.network(
                                                                                    imageUrl,
                                                                                    height: 30,
                                                                                    width: 30,
                                                                                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
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
                                                                        if (comment['replies'].length >
                                                                            1)
                                                                          TextButton(
                                                                              onPressed: () {
                                                                                replyState(() {
                                                                                  showAllReplies = !showAllReplies;
                                                                                });
                                                                              },
                                                                              child: Align(
                                                                                alignment: Alignment.centerLeft,
                                                                                child: Text(                                                                                  
                                                                                  isTranslated
                                                                                    ? showAllReplies
                                                                                        ? translatedHideReplies
                                                                                        : translatedShowReplies
                                                                                    : showAllReplies
                                                                                        ? 'Hide'
                                                                                        : 'Show all replies (${comment['replies'].length})',
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
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width:MediaQuery.of(context).size.width *0.80,
                                                    child: TextFormField(
                                                      controller:
                                                          _commentController,
                                                      decoration:
                                                          InputDecoration(
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        hintText:isTranslated  
                                                        ? parentId ==null
                                                          ? translatedNewComment
                                                          : translatedReplyComment
                                                        : parentId == null
                                                          ? 'Add a new comment'
                                                          : 'Reply to comment',
                                                        suffixIcon: _isReplyMode
                                                            ? IconButton(
                                                                icon: const Icon(Icons.cancel_sharp),
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
                                                            borderRadius:BorderRadius.circular(20.0)),
                                                        focusedBorder:OutlineInputBorder(
                                                          borderRadius:BorderRadius.circular(20.0),
                                                          borderSide:const BorderSide(color: Colors.black),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10.0),
                                                  IconButton.filled(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 10.0),
                                                      onPressed: () {
                                                        setState((){
                                                          _addComment(_commentController.text);
                                                        });
                                                      },
                                                      icon: const Icon(Icons.send))
                                                ],
                                              )),
                                        ],
                                      ),
                                    );
                                  });
                                });
                          },
                          child: Text(
                            isTranslated ? translatedButton : 'Comment',
                              style: const TextStyle(color: Colors.white)),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            isTranslated ? translatedPostContent : parsedData,
                            // translatedPostContent,
                            style: const TextStyle(fontSize: 16),
                          )),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              isTranslated ? translatedPostAuthor : 'Author: ${_post!['authors']['display']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              isTranslated ? translatedPostCDate : 'Created Date: ${_formatDate(_post!['timestamp'])}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              isTranslated ? translatedPostPDate : 'Published Date: ${_formatDate(_post!['utimestamp'])}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              isTranslated ? translatedTags : 'Tags: ${_getTagTitles(_post!['tag'])}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              isTranslated ? translatedCategory : 'Category: ${_categoryMap[_post!['category']]}',
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



//using only Batch processing
//   Future<void> _translateData() async {
//   try {
//     final translations = await Future.wait([
//       translator.translate(postTitle, to: 'hi'),
//       translator.translate(parsedData, to: 'hi'),
//       translator.translate('Author: ${_post!['authors']['display']}', to: 'hi'),
//       translator.translate('Created Date: ${_formatDate(_post!['timestamp'])}', to: 'hi'),
//       translator.translate('Published Date: ${_formatDate(_post!['utimestamp'])}', to: 'hi'),
//       translator.translate('Tags: ${_getTagTitles(_post!['tag'])}', to: 'hi'),
//       translator.translate('Category: ${_categoryMap[_post!['category']]}', to: 'hi'),
//       translator.translate(text, to: 'hi'),
//       translator.translate('Reply', to: 'hi'),
//       translator.translate('Hide', to: 'hi'),
//       translator.translate('Show all replies', to: 'hi'),
//       translator.translate('Add a new comment', to: 'hi'),
//       translator.translate('Reply to comment', to: 'hi'),
//     ]);

//     final List<Map<String, dynamic>> translatedComments = [];

//     for (var comment in _comments) {
//       var translatedUsername = await translator.translate(comment['users']['username'], to: 'hi');
//       var translatedContent = await translator.translate(comment['content'], to: 'hi');

//       List<Map<String, dynamic>> translatedReplies = [];
//       for (var reply in comment['replies']) {
//         var translatedReplyUsername = await translator.translate(reply['users']['username'], to: 'hi');
//         var translatedReplyContent = await translator.translate(reply['content'], to: 'hi');
//         translatedReplies.add({
//           'users': {'username': translatedReplyUsername.text},
//           'content': translatedReplyContent.text,
//         });
//       }

//       translatedComments.add({
//         'id': comment['id'],
//         'users': {'username': translatedUsername.text},
//         'content': translatedContent.text,
//         'replies': translatedReplies,
//       });
//     }

//     setState(() {
//       isTranslated = true;
//       translatedPostTitle = translations[0].text;
//       translatedPostContent = translations[1].text;
//       translatedPostAuthor = translations[2].text;
//       translatedPostCDate = translations[3].text;
//       translatedPostPDate = translations[4].text;
//       translatedTags = translations[5].text;
//       translatedCategory = translations[6].text;
//       translatedButton = translations[7].text;
//       translatedReplyTextButton = translations[8].text;
//       translatedHideReplies = translations[9].text;
//       translatedShowReplies = translations[10].text;
//       translatedNewComment = translations[11].text;
//       translatedReplyComment = translations[12].text;
//       translatedCommentsList = translatedComments;
//     });
//   } catch (e) {
//     print('Error translating data: $e');
//   }
// }



// parallel requests 
//   Future<void> _translateData() async {
//   try {
//     final List<Future<String>> translationFutures = [];

//     // Translate static content
//     translationFutures.addAll([
//       translator.translate(postTitle, to: 'hi').then((value) => value.text),
//       translator.translate(parsedData, to: 'hi').then((value) => value.text),
//       translator.translate('Author: ${_post!['authors']['display']}', to: 'hi').then((value) => value.text),
//       translator.translate('Created Date: ${_formatDate(_post!['timestamp'])}', to: 'hi').then((value) => value.text),
//       translator.translate('Published Date: ${_formatDate(_post!['utimestamp'])}', to: 'hi').then((value) => value.text),
//       translator.translate('Tags: ${_getTagTitles(_post!['tag'])}', to: 'hi').then((value) => value.text),
//       translator.translate('Category: ${_categoryMap[_post!['category']]}', to: 'hi').then((value) => value.text),
//       translator.translate(text, to: 'hi').then((value) => value.text),
//       translator.translate('Reply', to: 'hi').then((value) => value.text),
//       translator.translate('Hide', to: 'hi').then((value) => value.text),
//       translator.translate('Show all replies', to: 'hi').then((value) => value.text),
//       translator.translate('Add a new comment', to: 'hi').then((value) => value.text),
//       translator.translate('Reply to comment', to: 'hi').then((value) => value.text),
//     ]);

//     // Translate comments and replies
//     final List<Map<String, dynamic>> translatedComments = [];
//     for (var comment in _comments) {
//       translationFutures.add(translator.translate(comment['users']['username'], to: 'hi').then((value) => value.text));
//       translationFutures.add(translator.translate(comment['content'], to: 'hi').then((value) => value.text));

//       List<Future<Map<String, dynamic>>> replyFutures = [];
//       for (var reply in comment['replies']) {
//         replyFutures.add(translator.translate(reply['users']['username'], to: 'hi').then((value) => value.text)
//             .then((translatedReplyUsername) => translator.translate(reply['content'], to: 'hi').then((value) => value.text)
//             .then((translatedReplyContent) => ({
//                 'users': {'username': translatedReplyUsername},
//                 'content': translatedReplyContent,
//               }),
//             ),
//           ),
//         );
//       }

//       // Wait for all replies to be translated before adding them to the comment
//       List<Map<String, dynamic>> translatedReplies = await Future.wait(replyFutures);
//       translatedComments.add({
//         'id': comment['id'],
//         'users': {'username': await translationFutures[translationFutures.length - 2]},
//         'content': await translationFutures[translationFutures.length - 1],
//         'replies': translatedReplies,
//       });
//     }

//     // Wait for all translations to complete
//     List<String> translations = await Future.wait(translationFutures);

//     setState(() {
//       isTranslated = true;
//       translatedPostTitle = translations[0];
//       translatedPostContent = translations[1];
//       translatedPostAuthor = translations[2];
//       translatedPostCDate = translations[3];
//       translatedPostPDate = translations[4];
//       translatedTags = translations[5];
//       translatedCategory = translations[6];
//       translatedButton = translations[7];
//       translatedReplyTextButton = translations[8];
//       translatedHideReplies = translations[9];
//       translatedShowReplies = translations[10];
//       translatedNewComment = translations[11];
//       translatedReplyComment = translations[12];
//       translatedCommentsList = translatedComments;
//     });
//   } catch (e) {
//     print('Error translating data: $e');
//   }
// }


//simplest 

  //   Future<void> _translateData() async {
  //   try {
  //     var titleTranslate = await translator.translate(postTitle, to: 'hi');
  //     var contentTranslate = await translator.translate(parsedData, to: 'hi');
  //     var authorTranslate = await translator.translate('Author: ${_post!['authors']['display']}' , to: 'hi');
  //     var createdDate = await translator.translate('Created Date: ${_formatDate(_post!['timestamp'])}' , to: 'hi');
  //     var publishedDate = await translator.translate('Published Date: ${_formatDate(_post!['utimestamp'])}' , to: 'hi');
  //     var tagsTranslate = await translator.translate('Tags: ${_getTagTitles(_post!['tag'])}', to: 'hi');
  //     var categoryTranslate = await translator.translate('Category: ${_categoryMap[_post!['category']]}', to: 'hi');
  //     var commentButton = await translator.translate(text , to: 'hi');
  //     var replyTextButton = await translator.translate('Reply', to: 'hi');
  //     var hideReplies = await translator.translate('Hide', to: 'hi');
  //     var showReplies = await translator.translate('Show all replies' , to: 'hi');
  //     var newComment = await translator.translate('Add a new comment' , to: 'hi');
  //     var replyComment = await translator.translate('Reply to comment' , to: 'hi');

  //     List<Map<String, dynamic>> translatedComments = [];
  //     for (var comment in _comments) {
  //       var translatedUsername = await translator.translate(comment['users']['username'], to: 'hi');
  //       var translatedContent = await translator.translate(comment['content'], to: 'hi');

  //       List<Map<String, dynamic>> translatedReplies = [];
  //       for (var reply in comment['replies']) {
  //         var translatedReplyUsername = await translator.translate(reply['users']['username'], to: 'hi');
  //         var translatedReplyContent = await translator.translate(reply['content'], to: 'hi');
  //         translatedReplies.add({
  //           'users': {'username': translatedReplyUsername.text},
  //           'content': translatedReplyContent.text,
  //         });
  //       }

  //       translatedComments.add({
  //         'id' : comment['id'],
  //         'users': {'username': translatedUsername.text},
  //         'content': translatedContent.text,
  //         'replies': translatedReplies,
  //       });
  //     }

  //     setState(() {
  //       isTranslated = true;
  //       translatedPostTitle = titleTranslate.text;
  //       translatedPostContent = contentTranslate.text;
  //       translatedPostAuthor = authorTranslate.text;
  //       translatedPostCDate = createdDate.text;
  //       translatedPostPDate = publishedDate.text;
  //       translatedTags = tagsTranslate.text;
  //       translatedCategory = categoryTranslate.text;
  //       translatedButton = commentButton.text;
  //       translatedCommentsList = translatedComments;
  //       translatedReplyTextButton = replyTextButton.text;
  //       translatedHideReplies = hideReplies.text;
  //       translatedShowReplies = showReplies.text;
  //       translatedNewComment = newComment.text;
  //       translatedReplyComment = replyComment.text;

  //     });
  //   } catch (e) {
  //     print('Error translating title: $e');
  //   }
  // }
