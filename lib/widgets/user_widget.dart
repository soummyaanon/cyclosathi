import 'package:flutter/material.dart';

class UserWidget extends StatelessWidget {
  final String user;

  const UserWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850], // Dark background color for the card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Rounded corners
      ),
      elevation: 5.0, // Shadow effect
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          user,
          style: const TextStyle(
            color: Colors.white, // White text for contrast
            fontSize: 16.0, // Slightly larger font size
            fontWeight: FontWeight.bold, // Bold font weight
          ),
        ),
      ),
    );
  }
}