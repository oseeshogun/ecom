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
  final int categoryIndex;
  final String money;
  final List<String> urls;
  final String id;

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
    required this.categoryIndex,
    required this.brand,
    required this.condition,
    required this.money,
    required this.urls,
    required this.id,
  });

  static Product fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Product(
      id: doc.id,
      title: doc.data()?["title"] ?? "Sans titre",
      description: doc.data()?["description"] ?? "",
      sizes: doc.data()?["sizes"] ?? [],
      clicks: doc.data()?["clicks"] ?? 0,
      needIntSize: doc.data()?["needIntSize"] ?? false,
      price: doc.data()?["price"] ?? 0,
      author: doc.data()?["author"] ?? "",
      category: doc.data()?["category"] ?? "",
      categoryIndex: doc.data()?["categoryIndex"] ?? "",
      brand: doc.data()?["brand"] ?? "",
      condition: doc.data()?["condition"] ?? "excellent",
      money: doc.data()?["money"] ?? "cdf",
      urls: List.from(doc.data()?["urls"]).map<String>((url) {
        return url as String;
      }).toList(),
    );
  }

  String get moneySign {
    if (money.toLowerCase() == "usd") return "\$";
    return "Fc";
  }
}
