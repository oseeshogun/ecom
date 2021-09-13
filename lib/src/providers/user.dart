import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/src/models/user.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final userProvider = StreamProvider.family<User, String>((ref, uid){
  return FirebaseFirestore.instance.collection("users").doc(uid).snapshots().asyncMap((doc) {
    return User(
      image: doc.data()?["image"] ?? "",
      name: doc.data()?["name"] ?? ""
    );
  });
});