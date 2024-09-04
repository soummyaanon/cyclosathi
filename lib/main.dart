import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/report_screen.dart';
import 'screens/issue_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/authority_home_screen.dart';

final logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();
  runApp(const MyApp());
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    logger.i("Firebase initialized successfully");
  } catch (e) {
    logger.e("Error initializing Firebase: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cyclosathi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      onGenerateRoute: (settings) {
        if (settings.name == '/issue') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) {
              return IssueScreen(issueKey: args['issueKey']);
            },
          );
        }
        return null;
      },
      routes: {
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/report': (context) => const ReportScreen(),
        '/feed': (context) => const FeedScreen(issues: []),
        '/authorityHome': (context) => const AuthorityHomeScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            logger.i("User is null, returning LoginScreen");
            return const LoginScreen();
          } else {
            logger.i("User is not null, checking if authority");
            return FutureBuilder<bool>(
              future: _isAuthority(user),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data == true) {
                    logger.i("User is authority, returning AuthorityHomeScreen");
                    return const AuthorityHomeScreen();
                  } else {
                    logger.i("User is not authority, returning HomeScreen");
                    return const HomeScreen();
                  }
                }
                logger.i("Still checking authority, returning LoadingScreen");
                return const LoadingScreen();
              },
            );
          }
        }
        logger.i("Auth state not yet active, returning LoadingScreen");
        return const LoadingScreen();
      },
    );
  }

  Future<bool> _isAuthority(User user) async {
    try {
      logger.i("Checking authority for user: ${user.uid}");
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        bool isAuthority = userData['isAuthority'] ?? false;
        logger.i("User document exists. isAuthority: $isAuthority");
        return isAuthority;
      }
      logger.i("User document does not exist");
      return false;
    } catch (e) {
      logger.e("Error checking user authority: $e");
      return false;
    }
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade100,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
            SizedBox(height: 20),
            Text(
              'Loading Cyclosathi...',
              style: TextStyle(
                color: Colors.deepPurple,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}