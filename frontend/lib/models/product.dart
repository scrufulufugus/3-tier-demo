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

Future<Product> fetchProduct(int id, {String? token}) async {
  final response = await http
      .get(Uri.parse('$endpoint/product/$id'),
        headers: <String, String>{
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else if (response.statusCode == 404) {
    return Future.error('Product not found');
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to get product');
  }
}

Future<List<int>> fetchProductIds({String? token}) async {
  final response = await http
      .get(Uri.parse('$endpoint/products'),
        headers: <String, String>{
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

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

Future<List<Future<Product>>> fetchProducts({String? token}) async {
  final response = await fetchProductIds(token: token);

  return response.map((id) => fetchProduct(id, token: token)).toList();
}
