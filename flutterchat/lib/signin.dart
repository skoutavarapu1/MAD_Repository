import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutterchat/googleAuth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterchat/chatRoomScreen.dart';
import 'package:flutterchat/googleAuth.dart';
import 'package:flutterchat/main.dart';
import 'package:flutterchat/register.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignIn();
}

class _SignIn extends State<SignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _display = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Chat App"),
        ),
        body: Center(
            child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: TextFormField(
                          controller: _email,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter Email',
                            //  labelStyle: TextStyle(color: Colors.white54)
                          ),
                          validator: (String? text) {
                            if (text == null || text.isEmpty) {
                              return "Your forgot to enter email address";
                            }
                            return null;
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: TextFormField(
                          controller: _password,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter Password',
                          ),
                          validator: (String? text) {
                            if (text == null || text.length < 6) {
                              return "Your password field must contain atleast 6 characters";
                            }
                            return null;
                          }),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              // _loading = true;
                              _formKey.currentState!.validate()
                                  ? logIn(context)
                                  : null;
                            });
                          },
                          child: const Text("Sign In"),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              // _loading = true;
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RegisterPage()));
                            });
                          },
                          child: const Text("Register"),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: ElevatedButton(
                        onPressed: () {
                          final provider = Provider.of<GoogleSignInClass>(
                              context,
                              listen: false);
                          provider.googleLogin(context);
                        },
                        child: const Text("Signin with Google"),
                      ),
                    ),
                  ],
                ))));
  }

  void logIn(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: _email.text, password: _password.text);
        User? user = userCredential.user;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => chatRoom()));
      } on FirebaseAuthException catch (e) {
        if (e.code == "Wrong Password" || e.code == "no email") {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Incorrect email/Password")));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}
