import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fanpageapp/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _Register();
}

class _Register extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _firstname = TextEditingController();
  final _lastname = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Registration"),
          leading: new IconButton(
              icon: new Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => SignInPage()));
              }),
        ),
        body: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                          controller: _firstname,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter First Name',
                          ),
                          validator: (String? text) {
                            if (text == null || text.isEmpty) {
                              //context:
                              // const Text("Please enter your first name");
                              return "Please enter your first name";
                            }
                            return null;
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                          controller: _lastname,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter Last Name',
                          ),
                          validator: (String? text) {
                            if (text == null || text.isEmpty) {
                              return "Please enter your last name";
                            }
                            return null;
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                          controller: _email,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Email',
                          ),
                          validator: (String? text) {
                            if (text == null || text.isEmpty) {
                              return "Your forgot to enter email address";
                            }
                            return null;
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                          controller: _password,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Password',
                          ),
                          validator: (String? text) {
                            if (text == null || text.length < 6) {
                              return "Your password field must contain atleast 6 characters";
                            }
                            return null;
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Re-enter Password',
                        ),
                        validator: (String? text) {
                          if (text == null || text.length < 6) {
                            return "Your password field must contain atleast 6 characters";
                          } else if (text != _password.text) {
                            return "your password doesn't match";
                          }
                          return null;
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        _formKey.currentState!.validate()
                            ? register(context, "USER")
                            : null;
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder:(context)=>SignInPage()));
                      },
                      child: const Text("Register"),
                    ),
                  ],
                ))));
  }

  void register(BuildContext context, String role) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
              email: _email.text, password: _password.text);
      User? user = userCredential.user;
      _db.collection("users").doc(user!.uid).set({
        "userId": user.uid,
        "firstName": _firstname.text,
        "lastName": _lastname.text,
        "Email": _email.text,
        // "Password": _password.text,
        "role": role,
        "createdAt": DateTime.now()
      }).then((value) => {
            showDialog(
              context: context,
              builder: (BuildContext) => AlertDialog(
                title: Text('Alert'), // To display the title it is optional
                content: Text(
                    'Registration Successful'), // Message which will be pop up on the screen
                // Action widget which will provide the user to acknowledge the choice
                actions: [
                  FlatButton(
                    // FlatButton widget is used to make a text to work like a button
                    textColor: Color.fromARGB(255, 204, 4, 4),
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterPage()));
                    }, // function used to perform after pressing the button
                    child: Text('CANCEL'),
                  ),
                  FlatButton(
                    textColor: Color.fromARGB(255, 42, 122, 73),
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignInPage()));
                    },
                    child: Text('ACCEPT'),
                  ),
                ],
              ),
            )
            /*ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registerd successfully"))),*/
          });
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
