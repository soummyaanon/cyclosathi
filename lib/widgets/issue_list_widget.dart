import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../screens/issue_screen.dart';

class IssueListWidget extends StatefulWidget {
  const IssueListWidget({super.key});

  @override
  _IssueListWidgetState createState() => _IssueListWidgetState();
}

class _IssueListWidgetState extends State<IssueListWidget> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('disasterReports');
  List<Map<String, dynamic>> _issues = [];

  @override
  void initState() {
    super.initState();
    _listenForIssues();
  }

  void _listenForIssues() {
    _database.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        final List<Map<String, dynamic>> issues = [];
        data.forEach((key, value) {
          final issue = Map<String, dynamic>.from(value);
          issue['id'] = key;
          issues.add(issue);
        });
        setState(() {
          _issues = issues;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Disaster Reports',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _issues.length,
          itemBuilder: (context, index) {
            final issue = _issues[index];
            return IssueCard(issue: issue);
          },
        ),
      ],
    );
  }
}

class IssueCard extends StatelessWidget {
  final Map<String, dynamic> issue;

  const IssueCard({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.grey[800],
      child: ListTile(
        leading: Icon(_determineIcon(issue['disasterType']), 
                     color: _determineSeverityColor(issue['disasterType'])),
        title: Text(
          issue['disasterType'] ?? 'Unknown Disaster Type',
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDate(issue['incidentDate']),
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'People Affected: ${issue['peopleAffected']}',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IssueScreen(issueKey: issue['id']),
            ),
          );
        },
      ),
    );
  }

  IconData _determineIcon(String? disasterType) {
    switch (disasterType) {
      case 'Hurricane':
        return Icons.tornado;
      case 'Earthquake':
        return Icons.terrain;
      case 'Flood':
        return Icons.waves;
      case 'Wildfire':
        return Icons.local_fire_department;
      case 'Tsunami':
        return Icons.tsunami;
      case 'Landslide':
        return Icons.landscape;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  Color _determineSeverityColor(String? disasterType) {
    switch (disasterType) {
      case 'Hurricane':
      case 'Earthquake':
      case 'Tsunami':
        return Colors.red;
      case 'Flood':
      case 'Wildfire':
        return Colors.orange;
      case 'Landslide':
      default:
        return Colors.yellow;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown Date';
    final DateTime date = DateTime.parse(dateString);
    return DateFormat('MMM d, yyyy').format(date);
  }
}