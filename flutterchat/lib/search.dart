import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterchat/UserChatScreen.dart';
import 'package:flutterchat/database.dart';
import 'package:flutterchat/profile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchTextEditingController =
      new TextEditingController();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  String searchvalue = '';
  Stream<QuerySnapshot> searchSnapshot =
      FirebaseFirestore.instance.collection("users").snapshots();
  FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference allUsers = FirebaseFirestore.instance.collection("users");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search users"),
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
                      searchvalue = value;
                      searchSnapshot = allUsers
                          .where('firstName',
                              isGreaterThanOrEqualTo: searchvalue)
                          .where('firstName',
                              isLessThan: searchvalue + '\uf7ff')
                          .snapshots();
                    });
                  },
                  decoration: InputDecoration(
                      hintText: "Search with user name",
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade600,
                        size: 20,
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
                stream: searchSnapshot,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text("An error occurred. Please try again later",
                            style:
                                TextStyle(fontSize: 20.0, color: Colors.red)));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Colors.red,
                    ));
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No users available.',
                            style:
                                TextStyle(fontSize: 20.0, color: Colors.red)));
                  }

                  // No error/wait time return listview
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
                                // padding: EdgeInsets.only(top: 16),
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      // print("name ");
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => profile(
                                                    user: FirebaseFirestore
                                                        .instance
                                                        .collection("users")
                                                        .doc(document.id)
                                                        .get(),
                                                    isMyProfile: FirebaseAuth
                                                            .instance
                                                            .currentUser
                                                            ?.uid ==
                                                        document.id,
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
                                                // CircleAvatar(
                                                //     radius: 30.0,
                                                //     backgroundColor:
                                                //         const Color.fromARGB(
                                                //             31, 43, 43, 43),
                                                //     child: CircleAvatar(
                                                //       backgroundImage: data[
                                                //                   "imageURL"] ==
                                                //               "Null"
                                                //           ? const AssetImage(
                                                //                   "assets/dummy_user.jpg")
                                                //               as ImageProvider
                                                //           : NetworkImage(
                                                //               data["imageURL"]),
                                                //       maxRadius: 28,
                                                //     )),
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
                                                          data["Email"],
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              color: Colors.grey
                                                                  .shade600),
                                                        ),
                                                        Text(
                                                          data["numOfRaters"] !=
                                                                  0
                                                              ? "Rated: " +
                                                                  data["rating"]
                                                                      .toString() +
                                                                  "/5.0"
                                                              : "",
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              color: Colors.grey
                                                                  .shade600),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder:
                                                          (context) => userChat(
                                                                user: FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        "users")
                                                                    .doc(
                                                                        document
                                                                            .id)
                                                                    .get(),
                                                                // isMyProfile: FirebaseAuth
                                                                //         .instance
                                                                //         .currentUser
                                                                //         ?.uid ==
                                                                //     document.id,
                                                              )));
                                              print("Chat with " +
                                                  data["firstName"]);
                                            },
                                            icon: const Icon(Icons
                                                .messenger_outline_rounded),
                                            tooltip: "Send Message",
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
      // body: Container(
      //   child: Column(children: [
      //     Container(
      //       color: Color.fromARGB(255, 216, 215, 213),
      //       padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      //       child: Row(
      //         children: [
      //           Expanded(
      //               child: TextField(
      //             controller: searchTextEditingController,
      //             decoration: const InputDecoration(
      //               hintText: "Search username",
      //               border: InputBorder.none,
      //             ),
      //           )),
      //           GestureDetector(
      //             onTap: () {
      //               initiateSearch();
      //             },
      //             child: Container(
      //                 height: 40,
      //                 width: 40,
      //                 decoration: BoxDecoration(
      //                     gradient: LinearGradient(
      //                         colors: [Color(0x36FFFFFF), Color(0x0FFFFFFF)]),
      //                     borderRadius: BorderRadius.circular(40)),
      //                 padding: const EdgeInsets.all(10),
      //                 child: Image.asset("assets/images/searchimage.png")),
      //           )
      //         ],
      //       ),
      //     ),
      //     searchList()
      //   ]),
      // ),
    );
  }
}

class searchTile extends StatelessWidget {
  final String userName;
  final String userEmail;
  searchTile({required this.userName, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Column(
            children: [Text(userName), Text(userEmail)],
          ),
          Spacer(),
          Container(
            decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(30)),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text("Message"),
          )
        ],
      ),
    );
  }
}
