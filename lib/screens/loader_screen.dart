import 'package:flutter/material.dart';
import 'dart:async';

class LoaderScreen extends StatefulWidget {
  const LoaderScreen({super.key});

  @override
  _LoaderScreenState createState() => _LoaderScreenState();
}

class _LoaderScreenState extends State<LoaderScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToSignup();
  }

  _navigateToSignup() async {
    await Future.delayed(const Duration(seconds: 3)); // Adjust the duration as needed
    Navigator.pushReplacementNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Loading Disaster Management App...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
