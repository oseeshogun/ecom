
class Product {
  final String title;
  final String description;
  final double price;
  final int clicks;
  final String author;
  final String category;
  final String categoryDoc;
  // if t-shirt, the sizes available, S M L XL XXL
  final List<String> sizes;
  final bool needIntSize;

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
  });
}
