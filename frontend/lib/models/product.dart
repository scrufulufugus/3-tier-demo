import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/middleware.dart';

class ProductBase {
  final String title;
  final String description;
  final double price;
  final int? stock;
  final String imageUrl;

  const ProductBase({
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.stock,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'stock': stock,
      'image': imageUrl
    };
  }
}

class Product extends ProductBase {
  final int id;

  const Product({
      required this.id,
      required super.title,
      required super.description,
      required super.price,
      required super.imageUrl,
      super.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'title': String title,
        'description': String description,
        'price': double price,
        'stock': int? stock,
        'image': String imageUrl
      } => Product(
        id: id,
        title: title,
        description: description,
        price: price,
        stock: stock,
        imageUrl: imageUrl
      ),
      _ => throw FormatException('Invalid product JSON: $json')
    };
  }
}
