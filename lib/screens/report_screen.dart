import 'package:flutter/material.dart';
import '../widgets/report_widget.dart'; // Make sure to use the correct path

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
        backgroundColor: Colors.black, // Dark app bar
        automaticallyImplyLeading: false, // Remove the back button
      ),
      backgroundColor: Colors.grey[900], // Dark background
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Report Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ReportWidget(), // Use ReportWidget here
            ),
          ],
        ),
      ),
    );
  }
}