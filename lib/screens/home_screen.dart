import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/weather.dart';
import '../screens/report_screen.dart';
import '../widgets/issue_widget.dart';
import '../screens/login_screen.dart';

enum UserType { normal, authority }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  UserType _userType = UserType.normal;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _getUserType();
  }

  Future<void> _getUserType() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _userType = userDoc['isAuthority'] == true ? UserType.authority : UserType.normal;
      });
    }
  }

  List<Widget> _widgetOptions() => [
    _buildFeedPage(),
    _userType == UserType.normal ? const ReportScreen() : _buildAuthorityIssuePage(),
    const WeatherMapWidget(),
    _buildGuidePage(),
  ];

  Widget _buildFeedPage() {
    return ListView(
      children: const [
        IssueWidget(
          issue: "Flash flood warning in coastal areas",
          severity: "high",
          icon: Icons.flood,
        ),
        IssueWidget(
          issue: "Power outage in downtown district",
          severity: "medium",
          icon: Icons.power_off,
        ),
        IssueWidget(
          issue: "Road closure on Highway 101",
          severity: "low",
          icon: Icons.no_crash,
        ),
      ],
    );
  }

  Widget _buildAuthorityIssuePage() {
    return ListView(
      children: const [
        IssueWidget(
          issue: "Emergency shelter needed in Zone A",
          severity: "high",
          icon: Icons.home_work,
        ),
        IssueWidget(
          issue: "Medical supplies shortage at Central Hospital",
          severity: "medium",
          icon: Icons.local_hospital,
        ),
        IssueWidget(
          issue: "Volunteers needed for debris cleanup",
          severity: "low",
          icon: Icons.cleaning_services,
        ),
        // Add more IssueWidgets as needed for Authority users
      ],
    );
  }

  Widget _buildGuidePage() {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.fact_check, color: Color(0xFF4ECDC4)),
          title: const Text('Emergency Preparedness Checklist', style: TextStyle(color: Color(0xFFF0F0F0))),
          onTap: () {/* Navigate to checklist */},
        ),
        ListTile(
          leading: const Icon(Icons.call, color: Color(0xFF4ECDC4)),
          title: const Text('Emergency Contact Numbers', style: TextStyle(color: Color(0xFFF0F0F0))),
          onTap: () {/* Navigate to contacts */},
        ),
        ListTile(
          leading: const Icon(Icons.map, color: Color(0xFF4ECDC4)),
          title: const Text('Evacuation Routes', style: TextStyle(color: Color(0xFFF0F0F0))),
          onTap: () {/* Navigate to routes */},
        ),
      ],
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
        title: const Text('CycloSathi', style: TextStyle(color: Color(0xFF4ECDC4))),
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
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.dynamic_feed),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(_userType == UserType.normal ? Icons.report_problem : Icons.assignment),
            label: _userType == UserType.normal ? 'Report' : 'Issues',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'Weather',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: 'Guide',
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