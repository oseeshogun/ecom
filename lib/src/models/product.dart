import 'package:cloud_firestore/cloud_firestore.dart';

class ProductQuality {
  final String name;
  final String key;

  ProductQuality(this.name, this.key);
}

class Product {
  final String title;
  final String description;
  final double price;
  final int clicks;
  final String author;
  final String category;
  final String categoryDoc;

  /// if t-shirt, the sizes available, S M L XL XXL
  final List<String> sizes;
  final bool needIntSize;

  /// marque qui a fabriqué ce produit
  final String brand;

  /// excellent
  /// verygood
  /// good
  /// withdefaults
  /// bad
  final String condition;

  static List<ProductQuality> get conditions {
    return [
      ProductQuality("Excellente", "excellent"),
      ProductQuality("Très bien", "verygood"),
      ProductQuality("Bien", "good"),
      ProductQuality("Avec des défauts", "withdefaults"),
      ProductQuality("Mauvaise", "bad"),
    ];
  }

  Product({
    required this.title,
    required this.description,
    required this.price,
    required this.clicks,
    required this.author,
    required this.category,
    required this.sizes,
    required this.needIntSize,
    required this.categoryDoc,
    required this.brand,
    required this.condition,
  });

  static Product fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
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
        brand: doc.data()?["brand"] ?? "",
        condition: doc.data()?["condition"] ?? "excellent");
  }
}
