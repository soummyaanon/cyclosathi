import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
  apiKey: "AIzaSyDeg77f_DYxuvZ1_5QuUlqk4DA9KQjTrn0",
  authDomain: "cyclosathi.firebaseapp.com",
  databaseURL: "https://cyclosathi-default-rtdb.firebaseio.com",
  projectId: "cyclosathi",
  storageBucket: "cyclosathi.appspot.com",
  messagingSenderId: "250104548164",
  appId: "1:250104548164:web:18e91a24461e73be876511",
  measurementId: "G-3N9M8DL933"
    );
  }
}