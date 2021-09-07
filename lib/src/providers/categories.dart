import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/src/models/ecom_category.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final ecomCategoriesProvider = StreamProvider<List<EcomCategory>>((ref) {
  return FirebaseFirestore.instance
      .collection("categories")
      .orderBy("index")
      .snapshots()
      .asyncMap((query) {
    return query.docs
        .map<EcomCategory>((DocumentSnapshot<Map<String, dynamic>> doc) {
      final String colorString =
          "FF" + ((doc.data()?["color"] as String?)?.toUpperCase() ?? "F5F5F5");
      return EcomCategory(
        name: doc.data()?["name"] ?? "",
        color: Color(int.parse(colorString, radix: 16)),
        icon: Icon(
          IconData(doc.data()?["icon"] ?? 57672, fontFamily: 'MaterialIcons'),
          color: Colors.black,
        ),
      );
    }).toList();
  });
});

final selectedCategoryProvider = StateProvider<EcomCategory?>((ref) => null);
