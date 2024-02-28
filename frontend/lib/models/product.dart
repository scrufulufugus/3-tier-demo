import 'package:flutter/material.dart';

abstract class ProductList {
  List<Product> get products;
}

class Product {
  Product(this.id, this.title, this.description, this.price, this.imageUrl,
      {this.stock = 0});
  final int id;
  final String title;
  final String description;
  final double price;
  final int stock;
  final String imageUrl;
}
