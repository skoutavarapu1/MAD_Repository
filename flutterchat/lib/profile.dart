import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class profile extends StatefulWidget {
  final Future<DocumentSnapshot<Map<String, dynamic>>> user;
  final bool isMyProfile;
  const profile({Key? key, required this.user, required this.isMyProfile})
      : super(key: key);
  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  String name = '';
  String email = '';
  int rating = 0;
  bool alreadyRated = false;
  int numRated = 0;
  @override
  void initState() {
    super.initState();
    widget.user.then((DocumentSnapshot snapshot) {
      setState(() {
        name = snapshot["firstName"];
      });
      setState(() {
        email = snapshot["Email"];
      });
      setState(() {
        rating = snapshot["rating"];
      });
      setState(() {
        numRated = snapshot["numOfRaters"];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Center(
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Name : " + name,
                  style: TextStyle(fontSize: 22),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Email : " + email,
                  style: TextStyle(fontSize: 22),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Rating : " + rating.toString(),
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            widget.isMyProfile
                ? const Padding(padding: EdgeInsets.all(5.0))
                : (alreadyRated
                    ? const Text(
                        "Thanks for rating!",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      )
                    : RatingBar(
                        initialRating: 0,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        ratingWidget: RatingWidget(
                            full: const Icon(Icons.star, color: Colors.orange),
                            half: const Icon(
                              Icons.star_half,
                              color: Colors.orange,
                            ),
                            empty: const Icon(
                              Icons.star_outline,
                              color: Colors.orange,
                            )),
                        onRatingUpdate: (value) {
                          setState(() {
                            rating = ((((numRated) * (rating)) + value) /
                                    ((numRated) + 1))
                                .round();
                            numRated = numRated + 1;
                            alreadyRated = true;
                          });
                          widget.user.then((DocumentSnapshot snapshot) {
                            FirebaseFirestore.instance
                                .collection("users")
                                .doc(snapshot["userId"])
                                .set({
                              "Email": snapshot["Email"],
                              "createdAt": snapshot["createdAt"],
                              "firstName": snapshot["firstName"],
                              "rating": rating,
                              "role": snapshot["role"],
                              "userId": snapshot["userId"],
                              "numOfRaters": numRated
                            });
                          });
                        })),
          ],
        ),
      ),
    );
  }
}
