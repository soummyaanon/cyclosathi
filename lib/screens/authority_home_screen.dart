import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import '../widgets/issue_widget.dart';
import '../screens/login_screen.dart';
import '../widgets/weather.dart';

class AuthorityHomeScreen extends StatefulWidget {
  const AuthorityHomeScreen({super.key});

  @override
  AuthorityHomeScreenState createState() => AuthorityHomeScreenState();
}

class AuthorityHomeScreenState extends State<AuthorityHomeScreen> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAuthorityStatus();
  }

  Future<void> _checkAuthorityStatus() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          bool isAuthority = userData['isAuthority'] ?? false;
          if (!isAuthority) {
            setState(() {
              _errorMessage = "You do not have authority access.";
            });
          }
        } else {
          setState(() {
            _errorMessage = "User document not found.";
          });
        }
      } else {
        setState(() {
          _errorMessage = "No user signed in.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Widget> _widgetOptions() => [
    const WeatherMapWidget(),
    _buildAuthorityIssuePage(),
    _buildDashboardPage(),
  ];

  Widget _buildAuthorityIssuePage() {
    return StreamBuilder(
      stream: FirebaseDatabase.instance.ref('reports').onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: Text('No reports available'));
        }

        Map<dynamic, dynamic> reports = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

        return ListView(
          children: reports.entries.map((entry) {
            Map<dynamic, dynamic> report = entry.value as Map<dynamic, dynamic>;
            return IssueWidget(
              issue: report['reportDescription'] ?? 'No description',
              severity: _getSeverity(report['disasterType']),
              icon: _getIconForDisasterType(report['disasterType']),
            );
          }).toList(),
        );
      },
    );
  }

  String _getSeverity(String? disasterType) {
    switch (disasterType?.toLowerCase()) {
      case 'hurricane':
      case 'earthquake':
      case 'tsunami':
        return 'high';
      case 'flood':
      case 'wildfire':
        return 'medium';
      default:
        return 'low';
    }
  }

  IconData _getIconForDisasterType(String? disasterType) {
    switch (disasterType?.toLowerCase()) {
      case 'hurricane':
        return Icons.cyclone;
      case 'earthquake':
        return Icons.vibration;
      case 'flood':
        return Icons.water;
      case 'wildfire':
        return Icons.local_fire_department;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  Widget _buildDashboardPage() {
    return const Center(
      child: Text(
        'Dashboard Page (Add your dashboard widgets here)',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2639),
      appBar: AppBar(
        title: const Text('Authority Home', style: TextStyle(color: Color(0xFF4ECDC4))),
        backgroundColor: const Color(0xFF0F1725),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            color: const Color(0xFF4ECDC4),
            onPressed: _logout,
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _widgetOptions()[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Issues',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFFF6B6B),
        unselectedItemColor: const Color(0xFF4ECDC4),
        backgroundColor: const Color(0xFF0F1725),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      ),
    );
  }
}