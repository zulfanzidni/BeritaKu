import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in anonymously (for guest access)
  Future<User?> signInAnonymously() async {
    UserCredential result = await _auth.signInAnonymously();
    return result.user;
  }

  // Register User
  Future<User?> registerUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Registration Error: ${e.message}');
      return null;
    }
  }

  // Login User
  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Login Error: ${e.message}');
      return null;
    }
  }

  // Logout User
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get Current User
  //User? get currentUser => _auth.currentUser;
  User? getCurrentUser () {
    return _auth.currentUser;
  }
}
