import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/src/models/product.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final popularProductsProvider = StreamProvider<List<Product>>((ref){
  return FirebaseFirestore.instance.collection("products")
  .orderBy("clicks")
  .limit(100)
  .snapshots().asyncMap((query){
    return query.docs.map<Product>((DocumentSnapshot<Map<String, dynamic>> doc){
      return Product(
        title: doc.data()?["title"] ?? "Sans titre",
        description: doc.data()?["description"] ?? "",
        sizes: doc.data()?["sizes"] ?? [],
        clicks: doc.data()?["clicks"] ?? 0,
        needIntSize: doc.data()?["needIntSize"] ?? false,
        price: doc.data()?["price"] ?? 0,
        author: doc.data()?["author"] ?? "",
        category: doc.data()?["category"] ?? "",
        categoryDoc: doc.data()?["categoryDoc"] ?? "",
      );
    }).toList();
  });
});