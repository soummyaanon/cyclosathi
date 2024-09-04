import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../widgets/issue_list_widget.dart'; // Import the IssueListWidget

class IssueScreen extends StatelessWidget {
  final String issueKey;

  const IssueScreen({super.key, required this.issueKey});

  Future<Map?> _fetchIssueDetails() async {
    DatabaseReference issueRef = FirebaseDatabase.instance.ref().child('disasterReports').child(issueKey);
    DataSnapshot snapshot = await issueRef.get();
    if (snapshot.exists) {
      Map<String, dynamic> issueData = Map<String, dynamic>.from(snapshot.value as Map);
      issueData['id'] = issueKey;
      return issueData;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disaster Report Details'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[900],
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<Map?>(
              future: _fetchIssueDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('No details available', style: TextStyle(color: Colors.white)));
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: IssueDetailsWidget(issueData: Map<String, dynamic>.from(snapshot.data!)),
                  );
                }
              },
            ),
            const Divider(color: Colors.white),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Other Recent Issues',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const IssueListWidget(), // Add the IssueListWidget here
          ],
        ),
      ),
    );
  }
}

class IssueDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> issueData;

  const IssueDetailsWidget({super.key, required this.issueData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Disaster Type', issueData['disasterType']),
        _buildDetailRow('People Affected', issueData['peopleAffected']),
        _buildDetailRow('Incident Date', _formatDate(issueData['incidentDate'])),
        _buildDetailRow('Location', issueData['locationInput']),
        _buildDetailRow('Latitude', issueData['latitude']),
        _buildDetailRow('Longitude', issueData['longitude']),
        _buildDetailRow('Report Description', issueData['reportDescription']),
        _buildDetailRow('Immediate Needs', issueData['immediateNeeds']),
        _buildDetailRow('Reported On', _formatTimestamp(issueData['timestamp'])),
        _buildDetailRow('User ID', issueData['userId']),
      ],
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        '$label: ${value ?? 'N/A'}',
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown Date';
    final DateTime date = DateTime.parse(dateString);
    return DateFormat('MMM d, yyyy').format(date);
  }

  String _formatTimestamp(int? timestamp) {
    if (timestamp == null) return 'Unknown Time';
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MMM d, yyyy HH:mm:ss').format(date);
  }
}