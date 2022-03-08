import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterchat/googleAuth.dart';
import 'package:flutterchat/profile.dart';
import 'package:flutterchat/signin.dart';
import 'package:provider/provider.dart';

class userChat extends StatefulWidget {
  final Future<DocumentSnapshot<Map<String, dynamic>>> user;

  const userChat({Key? key, required this.user}) : super(key: key);

  @override
  userChatState createState() => userChatState();
}

class userChatState extends State<userChat> {
  final _form = GlobalKey<FormState>();
  final TextEditingController _messageTyped = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore _db = FirebaseFirestore.instance;
  String _receiverName = '';
  String _senderName = '';
  String _sentFrom = "";
  String _receivedBy = "";

  CollectionReference messages =
      FirebaseFirestore.instance.collection("messages");

  @override
  void initState() {
    super.initState();
    widget.user.then((DocumentSnapshot snapshot) {
      setState(() {
        _receiverName = snapshot["firstName"];
        _receivedBy = snapshot["userId"];
      });
    });
    _db
        .collection("users")
        .doc(auth.currentUser?.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      setState(() {
        _senderName = snapshot["firstName"];
        _sentFrom = snapshot["userId"];
      });
    });
  }

  Widget _logout(context) {
    return AlertDialog(
      title: const Text("Logout"),
      content: const Text("Confirm Logout?"),
      actions: [
        FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("No"),
            color: Color.fromARGB(255, 95, 199, 54),
            textColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.0))),
        FlatButton(
            onPressed: () async {
              await Provider.of<GoogleSignInClass>(context, listen: false)
                  .logout();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                  (Route route) => false);
            },
            child: const Text("Yes"),
            color: Color.fromARGB(255, 61, 137, 236),
            textColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.0))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _messageStream = FirebaseFirestore.instance
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: FlatButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            profile(user: widget.user, isMyProfile: false)));
              },
              child: Row(
                children: <Widget>[
                  const SizedBox(
                    width: 45,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          _receiverName,
                          style: const TextStyle(
                              fontSize: 22, color: Colors.white),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 61, 137, 236),
        actions: [],
      ),
      body: Form(
        key: _form,
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height - 180,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _messageStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text(
                                "An error occurred. Please try again later",
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Color.fromARGB(255, 61, 137, 236),
                                )));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 61, 137, 236),
                        ));
                      }

                      if (snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text('',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Color.fromARGB(255, 61, 137, 236),
                                )));
                      }

                      return SingleChildScrollView(
                        child: ListView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                                document.data()! as Map<String, dynamic>;

                            return SingleChildScrollView(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                  ListView.builder(
                                    itemCount: 1,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return ((data["sentBy"] == _sentFrom &&
                                                  data["sentTo"] ==
                                                      _receivedBy) ||
                                              (data["sentBy"] == _receivedBy &&
                                                  data["sentTo"] == _sentFrom))
                                          ? Container(
                                              padding: const EdgeInsets.only(
                                                  left: 14,
                                                  right: 14,
                                                  top: 10,
                                                  bottom: 10),
                                              child: Align(
                                                alignment: (data["sentBy"] ==
                                                        _receivedBy
                                                    ? Alignment.topLeft
                                                    : Alignment.topRight),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    color: (data["sentBy"] ==
                                                            _receivedBy
                                                        ? Colors.grey[600]
                                                        : Color.fromARGB(
                                                            255, 61, 137, 236)),
                                                  ),
                                                  padding: EdgeInsets.all(16),
                                                  child: Text(
                                                    data["body"],
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container();
                                    },
                                  )
                                ]));
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Container(
                  padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                  height: 65,
                  width: double.infinity,
                  child: Row(
                    children: <Widget>[
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: TextFormField(
                          validator: (value) {
                            return null;
                          },
                          controller: _messageTyped,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: const InputDecoration(
                              hintText: "Write message...",
                              hintStyle: TextStyle(color: Colors.black),
                              border: InputBorder.none),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      FloatingActionButton(
                        onPressed: () {
                          if (_form.currentState!.validate()) {
                            messages.add({
                              'body': _messageTyped.text,
                              'createdAt': DateTime.now(),
                              'sentBy': _sentFrom,
                              'sentTo': _receivedBy,
                            }).then((value) => {
                                  _messageTyped.clear(),
                                });
                            _db
                                .collection("users")
                                .doc(_sentFrom)
                                .collection("conversations")
                                .doc(_receivedBy)
                                .set({
                              "read": true,
                              "lastMessaged": DateTime.now(),
                              'firstName': _receiverName,
                              'userId': _receivedBy,
                              'lastMessage': _messageTyped.text
                            });
                            _db
                                .collection("users")
                                .doc(_receivedBy)
                                .collection("conversations")
                                .doc(_sentFrom)
                                .set({
                              "read": true,
                              "lastMessaged": DateTime.now(),
                              'firstName': _senderName,
                              'userId': _sentFrom,
                              'lastMessage': _messageTyped.text
                            });
                          }
                        },
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                        backgroundColor: Colors.blueAccent,
                        elevation: 0,
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54),
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
