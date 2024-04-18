import 'package:flutter/material.dart';

class UserDetailPage extends StatelessWidget {
  final dynamic data;

  const UserDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Split the data by commas
    List<String> details = data.toString().split(',');

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display each detail on a new line
            for (var detail in details)
              Text(detail.trim(), style: const TextStyle(fontSize: 18)),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Navigate back to the login page
              },
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}

