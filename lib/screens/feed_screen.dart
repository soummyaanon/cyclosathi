import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  final List<String> issues;

  const FeedScreen({super.key, required this.issues});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFADEDDE),
      appBar: AppBar(
        title: const Text('Feed'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: issues.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    issues[index],
                    style: const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    'More details about ${issues[index]}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/issue',
                        arguments: {'issueKey': issues[index]},
                      );
                    },
                    child: const Text('Show Details'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}