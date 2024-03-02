import 'dart:async';

import 'package:http/http.dart' as http;
import 'dart:convert';

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

Future<Product> fetchProduct(int id) async {
  final response = await http
      .get(Uri.parse('http://localhost:8000/product/$id'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to get product $id');
  }
}

Future<List<int>> fetchProductIds() async {
  final response = await http
      .get(Uri.parse('http://localhost:8000/products'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    List<dynamic> ids = jsonDecode(response.body) as List<dynamic>;
    return ids.map((id) => id as int).toList();
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to get product ids');
  }
}

Future<List<Future<Product>>> fetchProducts() async {
  final response = await fetchProductIds();

  return response.map((id) => fetchProduct(id)).toList();
}
