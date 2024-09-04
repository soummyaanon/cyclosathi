import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _logger = Logger();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  
  String? _name, _email, _password;
  bool _isLoading = false;

  Future<void> _processSignup() async {
    try {
      setState(() {
        _isLoading = true;
      });
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _email!,
        password: _password!,
      );
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': _name,
        'email': _email,
      });
      _logger.log(Level.info, 'User signed up successfully: ${userCredential.user!.uid}');
      
      // Show success dialog
      _showSuccessDialog();
    } catch (e) {
      _logger.log(Level.error, 'Error during signup: $e');
      _showErrorDialog('An unexpected error occurred. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Signup Successful'),
        content: const Text('Your account has been created successfully. Please log in.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Signup Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2639),
      appBar: AppBar(
        title: const Text('Signup', style: TextStyle(color: Color(0xFFF0F0F0))),
        backgroundColor: const Color(0xFF0F1725),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                const Icon(Icons.person_add, size: 100, color: Color(0xFFFF6B6B)),
                const SizedBox(height: 20),
                _buildTextField('Name', Icons.person),
                const SizedBox(height: 20),
                _buildTextField('Email', Icons.email),
                const SizedBox(height: 20),
                _buildTextField('Password', Icons.lock, isPassword: true),
                const SizedBox(height: 20),
                _isLoading 
                  ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)))
                  : _buildSignupButton(),
                const SizedBox(height: 10),
                _buildSignInButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, {bool isPassword = false}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFF0F0F0)),
        prefixIcon: Icon(icon, color: const Color(0xFF4ECDC4)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF4ECDC4)),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: const Color(0xFF0F1725),
      ),
      validator: (input) {
        if (input == null || input.isEmpty) {
          return 'Please enter $label';
        }
        if (label == 'Email' && !input.contains('@')) {
          return 'Please enter a valid email';
        }
        if (label == 'Password' && input.length < 8) {
          return 'Password must be at least 8 characters';
        }
        return null;
      },
      onSaved: (input) {
        switch (label) {
          case 'Name':
            _name = input;
            break;
          case 'Email':
            _email = input;
            break;
          case 'Password':
            _password = input;
            break;
        }
      },
      obscureText: isPassword,
      style: const TextStyle(color: Color(0xFFF0F0F0)),
    );
  }

  Widget _buildSignupButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState?.validate() ?? false) {
          _formKey.currentState?.save();
          _processSignup();
        }
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color(0xFF1A2639),
        backgroundColor: const Color(0xFFFF6B6B),
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
    );
  }

  Widget _buildSignInButton() {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacementNamed(context, '/login');
      },
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF4ECDC4),
      ),
      child: const Text('Already have an account? Sign In'),
    );
  }
}