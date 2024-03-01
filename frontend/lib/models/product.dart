import 'package:http/http.dart' as http;
import 'dart:convert';

class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final int stock;
  final String imageUrl;

  const Product({
      required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.stock = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'title': String title,
        'description': String description,
        'price': double price,
        'stock': int stock,
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
      .get(Uri.parse('http://localhost:8000/products/$id'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

Future<List<Product>> fetchProducts() async {
  final response = await http
      .get(Uri.parse('http://localhost:8000/products'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    List<Product> products = [];
    for (var product in jsonDecode(response.body) as List) {
      products.add(Product.fromJson(product as Map<String, dynamic>));
    }
    return products;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}
