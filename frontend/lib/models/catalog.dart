import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/product.dart';

abstract class Catalog extends ChangeNotifier {
  /// Internal, private state of the cart.
  @protected
  final List<int> productIds = [];
  List<Future<Product>> get products =>
      productIds.map((id) => fetchProduct(id)).toList();
  void add(int id);
  void remove(int id);
  void removeAt(int index);

  @protected
  static Future<Product> fetchProduct(int id, {String? token}) async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/product/$id'),
      headers: <String, String>{
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Product.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else if (response.statusCode == 404) {
      return Future.error('Product not found');
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to get product');
    }
  }

  @protected
  static Future<List<int>> fetchProductIds({String? token}) async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/products'),
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
}

class CatalogModel extends Catalog {
  CatalogModel();

  String? _token;
  set token(String? value) {
    _token = value;
    updateList();
  }

  @override
  List<Future<Product>> get products =>
      productIds.map((id) => fetchProduct(id, token: _token)).toList();

  void updateList() async {
    productIds.clear();
    if (_token != null) {
      productIds.addAll(await fetchProductIds(token: _token));
    } else {
      productIds.addAll(await fetchProductIds());
    }
    notifyListeners();
  }

  @override
  void add(int id) {
    productIds.add(id);
    notifyListeners();
  }

  @override
  void remove(int id) {
    if (productIds.remove(id)) {
      notifyListeners();
    }
  }

  @override
  void removeAt(int index) {
    productIds.removeAt(index);
    notifyListeners();
  }
}
