import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/src/models/product.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final popularProductsProvider = StreamProvider<List<Product>>((ref) {
  return FirebaseFirestore.instance
      .collection("products")
      .orderBy("clicks", descending: true)
      .limit(100)
      .snapshots()
      .asyncMap((query) {
    return query.docs
        .map<Product>((DocumentSnapshot<Map<String, dynamic>> doc) {
      return Product.fromDoc(doc);
    }).toList();
  });
});

final myproductsProvider =
    StreamProvider.family<List<Product>, String>((ref, uid) {
  return FirebaseFirestore.instance
      .collection("products")
      .where("author", isEqualTo: uid)
      .orderBy("timestamp")
      .snapshots()
      .asyncMap((query) {
    return query.docs
        .map<Product>((DocumentSnapshot<Map<String, dynamic>> doc) {
      return Product.fromDoc(doc);
    }).toList();
  });
});
