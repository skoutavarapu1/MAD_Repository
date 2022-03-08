import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  getUserByName(String username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("FirstName", isEqualTo: username)
        .snapshots();
  }
}
