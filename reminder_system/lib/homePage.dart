import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fanpageapp/googleAuth.dart';
import 'package:fanpageapp/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:provider/provider.dart';

//import 'addPost.dart';

class homePage extends StatefulWidget {
  const homePage({Key? key}) : super(key: key);

  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _message = TextEditingController();

  // String _user = FirebaseAuth.instance.currentUser!.uid;
  // var _storage = FirebaseFirestore.instance.collection("Users");
  // firebase_storage.FirebaseStorage _cloud =
  // firebase_storage.FirebaseStorage.instance;
  // String _usertype = "";

  bool isAdmin = false;
  String name = '';
  FirebaseFirestore _db = FirebaseFirestore.instance;
  var dateTimeFormat = DateFormat("M/d/y hh:mm");

  //_db.collection('messages').orderBy('createdAt').snapshots();
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('messages')
      .orderBy('createdAt')
      .snapshots();

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    print("******************************************** init state");

    _auth.authStateChanges().listen((User? user) {
      print("******************************************** suth state change");

      if (user == null) {
        print("******************************************** user null");
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const SignInPage()));
        // (Route route) => false);
      } else {
        // snapshot(user);
        print('********************************************* snapshot');
        print(user.uid);
        _db
            .collection('users')
            .doc(user.uid)
            .get()
            .then((DocumentSnapshot snapshot) {
          print("************************************************ document");
          print(snapshot.data().toString());
          if (snapshot["role"] == 'ADMIN') {
            setState(() {
              isAdmin = true;
            });
            print('Admin***************************************************');
          } else {
            setState(() {
              isAdmin = false;
            });
            print("Not admin **********************************************");
          }
          setState(() {
            name = snapshot['Email'];
            print("email***********************************************");
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        actions: [
          IconButton(
            onPressed: () async {
              signoutPopup(context);
              // await _auth.signOut();
              // Navigator.pushReplacement(context,
              //     MaterialPageRoute(builder: (context) => SignInPage()));
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return Column(
                children: [
                  Row(children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 15.0, bottom: 3.0, right: 20.0),
                          child: Text(
                            dateTimeFormat
                                .format(data['createdAt'].toDate())
                                .toString(),
                            textAlign: TextAlign.right,
                          ),
                        )),
                  ]),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0)),
                      title: Text(
                        data['message'],
                        style: const TextStyle(color: Colors.blueGrey),
                        textAlign: TextAlign.justify,
                      ),
                      tileColor: Colors.white,
                    ),
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => addpost(context));
                //Navigator.pushReplacement(context, MaterialPageRoute(builder:(context)=>AddPost()));
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget addpost(context) {
    return Dialog(
        child: Column(
      children: [
        Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: TextField(
              controller: _message,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Add your message here',
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 10,
            )),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    addMessage(context, _message.text);
                    Navigator.of(context).pop();
                    //Navigator.pushReplacement(context, MaterialPageRoute(builder:(context)=>Home()));
                  });
                },
                child: const Text("Post"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    // addMessage(context, _message.text);
                    Navigator.of(context).pop();
                    //Navigator.pushReplacement(context, MaterialPageRoute(builder:(context)=>Home()));
                  });
                },
                child: const Text("cancel"),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  void signoutPopup(context) async {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Alert'),
        content: const Text('Are you sure to logout'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<GoogleSignInClass>(context, listen: false)
                  .logout();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const SignInPage()));
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void addMessage(BuildContext context, String message) {
    var userName = _db.collection('users').doc().get();
    try {
      _db.collection("messages").add(
          {"message": message, "createdBy": name, "createdAt": DateTime.now()});
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
