import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return result.user.uid;
  }

  Future<User> signUp(String email, String password) async {
    UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    return result.user;
  }

  Future<User> getCurrentUser() async {
    User user = _firebaseAuth.currentUser;
    return user;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    User user =  _firebaseAuth.currentUser;
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    User user =  _firebaseAuth.currentUser;
    return user.emailVerified;
  }

  Future<User> singInUpWithCredential(AuthCredential credential) async {
    UserCredential result = await _firebaseAuth.signInWithCredential(credential);
    return result.user;
  }
}
