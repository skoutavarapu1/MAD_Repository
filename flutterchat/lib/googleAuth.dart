import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterchat/chatRoomScreen.dart';
import 'package:flutterchat/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInClass with ChangeNotifier {
  final GoogleSignIn _google = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
      clientId:
          '925390021434-1o6fmc5t73quelh3nmil3fcl2fpvhq0t.apps.googleusercontent.com');

  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;

  void _storeinFirestore(context) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference users = firestore.collection("users");

    var name = user.displayName?.split(' ');
    int? size = name?.length;
    var uid = FirebaseAuth.instance.currentUser?.uid;
    String string = "Welcome " + user.displayName!;

    try {
      users.doc(uid).get().then((DocumentSnapshot snapshot) => {
            if (!snapshot.exists)
              {
                users
                    .doc(uid)
                    .set({
                      'userId': uid,
                      'firstName': name![0],
                      // 'lastName': name[size! - 1],
                      'Email': user.email,
                      'role': 'USER',
                      "createdAt": DateTime.now(),
                      "rating": 0,
                      "numOfRaters": 0
                    })
                    .then((value) => {
                          showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                    title: const Text('Welcome!'),
                                    content: Text(string),
                                    actions: <Widget>[
                                      FlatButton(
                                          onPressed: () =>
                                              {Navigator.of(context).pop()},
                                          child: const Text('OK'),
                                          color: Colors.red.shade700,
                                          textColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32.0))),
                                    ],
                                  ))
                        })
                    .catchError((error) => {
                          showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                    title: const Text('Error Occurred!'),
                                    content: const Text(
                                        'Error in Signing In. Please try again.'),
                                    actions: <Widget>[
                                      FlatButton(
                                          onPressed: () =>
                                              {Navigator.of(context).pop()},
                                          child: const Text('OK'),
                                          color: Colors.red.shade700,
                                          textColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32.0))),
                                    ],
                                  ))
                        })
              }
            else
              {}
          });

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const chatRoom()));
    } catch (error) {
      print(error);
    }
  }

  Future googleLogin(context) async {
    final googleUser = await _google.signIn();
    if (googleUser == null) return;
    _user = googleUser;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);

      notifyListeners();
      _storeinFirestore(context);
    } catch (e) {
      print(e);
    }
  }

  Future logout() async {
    _google.disconnect;
    await _google.signOut();
    FirebaseAuth.instance.signOut();
  }
}
