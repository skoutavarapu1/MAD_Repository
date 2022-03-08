import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterchat/UserChatScreen.dart';
import 'package:flutterchat/googleAuth.dart';
import 'package:flutterchat/profile.dart';
import 'package:flutterchat/search.dart';
import 'package:flutterchat/signin.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class chatRoom extends StatefulWidget {
  const chatRoom({Key? key}) : super(key: key);

  @override
  chatRoomState createState() => chatRoomState();
}

class chatRoomState extends State<chatRoom> {
  String searchKey = '';
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  int _raters = 0;
  var format = DateFormat("M/d/y hh:mm a");
  double _rating = 0.0;
  String _name = '';

  CollectionReference messages =
      FirebaseFirestore.instance.collection("messages");
  Stream<QuerySnapshot<Map<String, dynamic>>> result = FirebaseFirestore
      .instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection("conversations")
      .orderBy("lastMessaged", descending: true)
      .snapshots();

  @override
  void initState() {
    super.initState();
    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SignInPage()),
            (Route route) => false);
      } else {
        firestore
            .collection('users')
            .doc(user.uid)
            .get()
            .then((DocumentSnapshot snapshot) {
          setState(() {
            _name = snapshot['firstName'];
            _rating = snapshot['rating'];
            _raters = snapshot['numOfRaters'];
          });
        });
      }
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
            color: Color.fromARGB(255, 61, 137, 236),
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
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SearchScreen()));
        },
        child: const Icon(Icons.search),
        tooltip: "Search Users",
        backgroundColor: Color.fromARGB(255, 61, 137, 236),
      ),
      appBar: AppBar(
        leading: Container(
            child: ConstrainedBox(
                constraints: BoxConstraints.expand(),
                child: FlatButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => profile(
                                    user: firestore
                                        .collection("users")
                                        .doc(auth.currentUser?.uid)
                                        .get(),
                                    isMyProfile: true,
                                  )));
                    },
                    padding: EdgeInsets.only(left: 20.0),
                    child: Icon(Icons
                        .person_add_alt_rounded) //   Icon(Icons.person_add_alt_1_rounded)

                    ))),
        title: const Text("My chats"),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 61, 137, 236),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => _logout(context));
            },
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          ),
        ],
      ),
      body: Column(
        children: [
          // SEARCH BAR
          SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 370,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchKey = value.toLowerCase();
                      result = FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .collection("conversations")
                          .where('firstName', isGreaterThanOrEqualTo: searchKey)
                          .where('firstName', isLessThan: searchKey + '\uf7ff')
                          .snapshots();
                    });
                  },
                  decoration: InputDecoration(
                      hintText: "Search for users here",
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade600,
                        size: 15,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0),
                      )),
                ),
              ),
            ),
          ),
          // LIST OF CONTACTS
          Expanded(
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: StreamBuilder<QuerySnapshot>(
                stream: result,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text("An error occurred. Please try again later",
                            style: TextStyle(
                                fontSize: 20.0, color: Colors.blueAccent)));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Colors.blueAccent,
                    ));
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('',
                            style: TextStyle(
                                fontSize: 20.0, color: Colors.blueAccent)));
                  }
                  return SingleChildScrollView(
                    child: ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;

                        return SingleChildScrollView(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                              ListView.builder(
                                itemCount: 1,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => userChat(
                                                    user: FirebaseFirestore
                                                        .instance
                                                        .collection("users")
                                                        .doc(document.id)
                                                        .get(),
                                                  )));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          left: 16,
                                          right: 16,
                                          top: 10,
                                          bottom: 10),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color.fromARGB(
                                                  31, 43, 43, 43))),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Row(
                                              children: <Widget>[
                                                const SizedBox(
                                                  width: 16,
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    color: Colors.transparent,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Text(
                                                          data["firstName"],
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 16),
                                                        ),
                                                        const SizedBox(
                                                          height: 6,
                                                        ),
                                                        Text(
                                                          data["lastMessage"],
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors
                                                                .grey.shade600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
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
        ],
      ),
    );
  }
}
