import 'package:equatable/equatable.dart';

class BookstoreCategory extends Equatable {
  const BookstoreCategory({
    required this.id,
    required this.name,
    required this.sortOrder,
  });

  factory BookstoreCategory.fromJson(Map<String, dynamic> json) {
    return BookstoreCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      sortOrder: json['sort_order'] as int,
    );
  }

  final String id;
  final String name;
  final int sortOrder;

  @override
  List<Object?> get props => [id, name, sortOrder];
}

class BookstoreProduct extends Equatable {
  const BookstoreProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.productType,
    required this.externalBuyUrl,
    required this.isActive,
    this.author,
    this.categoryId,
    this.imageUrl,
  });

  factory BookstoreProduct.fromJson(Map<String, dynamic> json) {
    return BookstoreProduct(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String?,
      price: double.parse(json['price'].toString()),
      productType: json['product_type'] as String,
      categoryId: json['category_id'] as String?,
      externalBuyUrl: json['external_buy_url'] as String,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool,
    );
  }

  final String id;
  final String title;
  final String? author;
  final double price;
  final String productType;
  final String? categoryId;
  final String externalBuyUrl;
  final String? imageUrl;
  final bool isActive;

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        price,
        productType,
        categoryId,
        externalBuyUrl,
        imageUrl,
        isActive,
      ];
}
