import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Home'),
      // ),
      body: const Center(
        child: Text('Home Page'),
        // child: Text('This is the content in home page that is made to test the navigation bar'),
      ),
    );
  }
}