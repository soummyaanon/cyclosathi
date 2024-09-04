import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportWidget extends StatefulWidget {
  const ReportWidget({super.key});

  @override
  ReportWidgetState createState() => ReportWidgetState();
}

class ReportWidgetState extends State<ReportWidget> {
  final _formKey = GlobalKey<FormState>();
  String? _reportDescription;
  String? _locationInput;
  Position? _currentPosition;
  String? _disasterType;
  String? _peopleAffected;
  DateTime? _incidentDate;
  String? _immediateNeedsDescription;

  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('disasterReports');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<String> _disasterTypes = [
    'Earthquake',
    'Flood',
    'Hurricane',
    'Wildfire',
    'Tsunami',
    'Landslide',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _signInAnonymously();
  }

  Future<void> _signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      print('Debug: Signed in anonymously with user ID: ${userCredential.user?.uid}');
    } on FirebaseAuthException catch (e) {
      print('Debug: FirebaseAuthException: ${e.code} - ${e.message}');
      String errorMessage = 'An error occurred during sign in.';
      if (e.code == 'admin-restricted-operation') {
        errorMessage = 'This operation is currently restricted. Please try again later or contact support.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      print('Debug: Unexpected error during sign in: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred. Please try again.')),
      );
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      
      if (_auth.currentUser == null) {
        print('Debug: User is not authenticated, attempting to sign in');
        await _signInAnonymously();
      }

      if (_auth.currentUser == null) {
        print('Debug: Failed to authenticate user');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to authenticate. Please try again.')),
        );
        return;
      }

      print('Debug: User authenticated with ID: ${_auth.currentUser?.uid}');

      // Prepare data for submission
      final data = {
        'disasterType': _disasterType,
        'peopleAffected': _peopleAffected,
        'incidentDate': _incidentDate?.toIso8601String(),
        'locationInput': _locationInput,
        'latitude': _currentPosition?.latitude,
        'longitude': _currentPosition?.longitude,
        'reportDescription': _reportDescription,
        'immediateNeeds': _immediateNeedsDescription,
        'timestamp': ServerValue.timestamp,
        'userId': _auth.currentUser?.uid,
      };

      print('Debug: Prepared data for submission: $data');

      // Send data to Firebase Realtime Database
      try {
        print('Debug: Attempting to send data to Firebase');
        final newReportRef = _database.push();
        await newReportRef.set(data);
        print('Debug: Data sent successfully. New report key: ${newReportRef.key}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully')),
        );
        // Clear form after successful submission
        _formKey.currentState?.reset();
        setState(() {
          _disasterType = null;
          _incidentDate = null;
          _locationInput = null;
          _currentPosition = null;
        });
      } catch (e) {
        print('Debug: Error submitting report: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting report: $e')),
        );
      }
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Debug: Location services are disabled');
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Debug: Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Debug: Location permissions are permanently denied');
        return;
      }

      print('Debug: Getting current position');
      Position position = await Geolocator.getCurrentPosition();
      print('Debug: Current position: $position');
      setState(() {
        _currentPosition = position;
        _locationInput = '${position.latitude}, ${position.longitude}';
      });
    } catch (e) {
      print('Debug: Error getting location: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _incidentDate) {
      setState(() {
        _incidentDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disaster Report Form'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Disaster Type',
                  border: OutlineInputBorder(),
                ),
                value: _disasterType,
                items: _disasterTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _disasterType = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select a disaster type' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Estimated Number of People Affected',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (input) => input?.isEmpty ?? true ? 'Please enter an estimate' : null,
                onSaved: (input) => _peopleAffected = input,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Incident Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text: _incidentDate != null
                          ? DateFormat('yyyy-MM-dd').format(_incidentDate!)
                          : '',
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please select the incident date' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Location',
                  hintText: 'Enter location manually or use GPS',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: _determinePosition,
                  ),
                ),
                controller: TextEditingController(text: _locationInput),
                onSaved: (input) => _locationInput = input,
                validator: (input) => input?.isEmpty ?? true ? 'Please enter a location or use GPS' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Report Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (input) => input?.isEmpty ?? true ? 'Please enter a report description' : null,
                onSaved: (input) => _reportDescription = input,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Immediate Needs Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (input) => _immediateNeedsDescription = input,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Submit Report', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}