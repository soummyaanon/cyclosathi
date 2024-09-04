import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum UserType { normal, authority }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _email, _password;
  UserType _userType = UserType.normal;
  bool _isLoading = false;

  // Predefined credentials for authority users
  final String _authorityEmail = 'authority@example.com';
  final String _authorityPassword = 'pass1234';

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      setState(() {
        _isLoading = true;
      });

      try {
        if (_userType == UserType.authority) {
          // Check credentials for authority users
          if (_email == _authorityEmail && _password == _authorityPassword) {
            Navigator.of(context).pushReplacementNamed('/authorityHome');
          } else {
            _showErrorDialog('Invalid authority credentials');
          }
        } else {
          // Normal user login process
          UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _email!,
            password: _password!,
          );
          if (userCredential.user != null) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        }
      } catch (e) {
        _showErrorDialog('Login failed: ${e.toString()}');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
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
        title: const Text('Login', style: TextStyle(color: Color(0xFFF0F0F0))),
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
                const Icon(Icons.lock_outline, size: 100, color: Color(0xFFFF6B6B)),
                const SizedBox(height: 30),
                _buildTextField('Email', Icons.email),
                const SizedBox(height: 20),
                _buildTextField('Password', Icons.lock, isPassword: true),
                const SizedBox(height: 20),
                _buildUserTypeSelection(),
                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)))
                    : _buildLoginButton(),
                const SizedBox(height: 15),
                _buildSignUpButton(),
                const SizedBox(height: 30),
                _buildConditionalContent(),
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
          return 'Please enter your $label';
        }
        if (label == 'Email' && !input.contains('@')) {
          return 'Please enter a valid email';
        }
        if (label == 'Password' && input.length < 8) {
          return 'Password must be at least 8 characters';
        }
        return null;
      },
      onSaved: (input) => label == 'Email' ? _email = input : _password = input,
      obscureText: isPassword,
      style: const TextStyle(color: Color(0xFFF0F0F0)),
    );
  }

  Widget _buildUserTypeSelection() {
    return Column(
      children: [
        ListTile(
          title: const Text('Normal User', style: TextStyle(color: Color(0xFFF0F0F0))),
          leading: Radio<UserType>(
            value: UserType.normal,
            groupValue: _userType,
            onChanged: (UserType? value) {
              setState(() {
                _userType = value!;
              });
            },
            activeColor: const Color(0xFF4ECDC4),
          ),
        ),
        ListTile(
          title: const Text('Authority', style: TextStyle(color: Color(0xFFF0F0F0))),
          leading: Radio<UserType>(
            value: UserType.authority,
            groupValue: _userType,
            onChanged: (UserType? value) {
              setState(() {
                _userType = value!;
              });
            },
            activeColor: const Color(0xFF4ECDC4),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _submit,
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color(0xFF1A2639),
        backgroundColor: const Color(0xFFFF6B6B),
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      child: const Text('Login', style: TextStyle(fontSize: 18)),
    );
  }

  Widget _buildSignUpButton() {
    return TextButton(
      onPressed: () {
        if (_userType == UserType.normal) {
          Navigator.pushNamed(context, '/signup');
        } else {
          _showErrorDialog('Authority users cannot sign up');
        }
      },
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF4ECDC4),
      ),
      child: const Text("Don't have an account? Sign Up"),
    );
  }

  Widget _buildConditionalContent() {
    if (_userType == UserType.authority) {
      return const Column(
        children: [
          Text('Authority Specific Content', style: TextStyle(color: Color(0xFFF0F0F0))),
          // Add more widgets specific to Authority here
        ],
      );
    } else {
      return const Column(
        children: [
          Text('Normal User Specific Content', style: TextStyle(color: Color(0xFFF0F0F0))),
          // Add more widgets specific to Normal User here
        ],
      );
    }
  }
}