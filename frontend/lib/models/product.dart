import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/middleware.dart';

class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final int? stock;
  final String imageUrl;

  const Product({
      required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.stock,
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
