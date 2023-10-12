

import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
//import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuthException;
import 'package:google_sign_in/google_sign_in.dart';



import 'user.dart';

/// Thrown if during the sign up process if a failure occurs.
class SignUpFailure implements Exception {}

/// Thrown during the login process if a failure occurs.
class LogInWithEmailAndPasswordFailure implements Exception {}

/// Thrown during the login process if a failure occurs.
class LogInAnonymouslyFailure implements Exception {}

class LogInWithFacebookFailure implements Exception {}

/// Thrown during the sign in with google process if a failure occurs.
class LogInWithGoogleFailure implements Exception {}

/// Thrown during the logout process if a failure occurs.
class LogOutFailure implements Exception {}

/// {@template authentication_repository}
/// Repository which manages user authentication.
/// {@endtemplate}
class AuthenticationRepository {
  /// {@macro authentication_repository}
  AuthenticationRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.standard();

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  //FirebaseManager firebaseManager = new FirebaseManager();
  //User _user =   firebase_auth.FirebaseAuth.instance.currentUser;

  /*if(!_user.emailVerified){
        var actionCodeSettings = ActionCodeSettings(
            url: 'https://www.example.com/?email=${_user.email}',
            dynamicLinkDomain: "example.page.link",
            /*android: {
              "packageName": "com.example.android",
              "installApp": true,
              "minimumVersion": "12"
            },*/
            androidPackageName: "com.lordyhas.exploress",
            androidMinimumVersion: "16",
            androidInstallApp: true,
            //iOS: {"bundleId": "com.example.ios"},
            handleCodeInApp: true);

        await _user.sendEmailVerification(actionCodeSettings);
      }   */


  /// Stream of [User] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [User.empty] if the user is not authenticated.
  Stream<User> get userAuth {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if(firebaseUser != null) {
        return firebaseUser.toUser;
      }

      return User.empty;
    });
  }

  /// Creates a new user with the provided [email] and [password].
  ///
  /// Throws a [SignUpFailure] if an exception occurs.
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    //assert(email != null && password != null);

    try {

      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );


    } on Exception {
      debugPrint("Exception : Sign Up With Mail failed => $Exception ");
      throw SignUpFailure();
    }
    /*on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }*/
  }

  /// Starts the Sign In Anonymously .
  ///
  /// Throws a [LogInAnonymouslyFailure] if an exception occurs.
  Future<void> logInAnonymously() async {
    try {
      await _firebaseAuth.signInAnonymously();
    } on Exception {
      debugPrint("Exception : Login Anonymously failed => $Exception ");
      throw LogInAnonymouslyFailure();
    }
  }

  /// Starts the Sign In with Google Flow.
  ///
  /// Throws a [LogInWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> logInWithGoogle() async {

    try {
      final googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
    } on Exception /*firebase_auth.FirebaseAuthException catch(e)*/ {
      debugPrint("Exception : Login With Google failed => $Exception ");
      throw LogInWithGoogleFailure();
    }
  }

  /// Signs in with the provided [email] and [password].
  ///
  /// Throws a [LogInWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    //assert(email != null && password != null);
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on Exception {
      //print();
      throw LogInWithEmailAndPasswordFailure();
    }
  }

  /// Starts the Sign In with Facebook .
  ///
  /// Throws a [LogInWithFacebookFailure] if an exception occurs.
  Future<void> logInWithFacebook() async {
    try {
      //await _firebaseAuth.signInAnonymously();
      /*final result = await FacebookAuth.instance.login() ;

      // Create a credential from the access token
      final firebase_auth.OAuthCredential facebookAuthCredential =
      firebase_auth.FacebookAuthProvider.credential(result!.token!);
      await _firebaseAuth.signInWithCredential(facebookAuthCredential);*/

    } on Exception {
      throw LogInWithFacebookFailure();
    }
  }



  /// Signs out the current user which will emit
  /// [User.empty] from the [userAuth] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } on Exception {
      throw LogOutFailure();
    }
  }
}

extension on firebase_auth.User {
  //bool get emailNotVerified => !emailVerified;

  User get toUser {

    return User(
        id: uid, email: email!,
        name: displayName, photoMail: photoURL,
        phoneNumber: phoneNumber,
        lastDate: metadata.lastSignInTime,
        creationDate: metadata.creationTime,
        isAnonymous: isAnonymous,
        isCheckMail: emailVerified,

    );
  }
}
