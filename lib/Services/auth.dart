import 'package:firebase_auth/firebase_auth.dart';
import '../MyAppClasses/UserToAuthentificate.dart';
import '../MyAppClasses/Utilisateur.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserToAuthentificate _userfromfirebase(User? user) {
    return UserToAuthentificate(user!.uid);
  }

  Stream<UserToAuthentificate> get user {
    return _auth.authStateChanges().map(
        _userfromfirebase);
  }

  Future<void> sendEmailVerification(User user) async {
    await user.sendEmailVerification();
  }

  // methode to login
  Future signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userfromfirebase(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // methode to sign up
  Future signUp(String email, String password, Utilisateur utilisateur) async {
    try {
      /*if (FirebaseAuth.instance.currentUser != null &&
          !FirebaseAuth.instance.currentUser!.emailVerified) {
        FirebaseAuth.instance.currentUser!.delete();
      }*/
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      utilisateur.identifiant = user!.uid;
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // methode to sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
