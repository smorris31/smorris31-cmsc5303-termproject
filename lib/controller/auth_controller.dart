import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  static Future<User?> signIn(
      {required String email, required String password}) async {
    //async always returns a future type so you need to wrap this function
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return userCredential.user;
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }


  static Future<void> createAccount({
    required String email,
    required String password,
  }) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
  }
}
