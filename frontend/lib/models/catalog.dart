import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/product.dart';

abstract class Catalog extends ChangeNotifier {
  @protected
  String? token_;
  @protected
  final List<int> productIds_ = [];
  @protected
  final Map<int, Future<Product>> prodCache_ = {};

  Future<Product> get(int id) => prodCache_.putIfAbsent(id, () => fetchProduct_(id));
  List<Future<Product>> get products =>
      productIds_.map((id) => get(id)).toList();
  operator [](index) => get(productIds_[index]);
  int get length => productIds_.length;

  void add(int id);
  void remove(int id);
  void removeAt(int index);

  @protected
  Future<Product> fetchProduct_(int id) async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/product/$id'),
      headers: <String, String>{
        if (token_ != null) 'Authorization': 'Bearer $token_',
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
  Future<List<int>> fetchProductIds_() async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/products'),
      headers: <String, String>{
        if (token_ != null) 'Authorization': 'Bearer $token_',
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

  set token(String? value) {
    token_ = value;
    updateList();
  }

  void updateList() async {
    productIds_.clear();
    prodCache_.clear();
    if (token_ != null) {
      productIds_.addAll(await fetchProductIds(token: token_));
    } else {
      productIds_.addAll(await fetchProductIds(token: token_));
    }
    notifyListeners();
  }

  @override
  void add(int id) {
    if (token_ == null) {
      throw Exception('Cannot add to catalog without a token');
    }
    productIds_.add(id);
  }

  /// TODO: Call to server and update list
  bool _remove(int id) {
    if (token_ == null) {
      throw Exception('Cannot remove from catalog without a token');
    }
    if (productIds_.remove(id)) {
      prodCache_.remove(id); // Drop from cache
      return true;
    }
    return false;
  }

  @override
  void remove(int id) {
    if (_remove(id)) {
      notifyListeners();
    }
  }

  @override
  void removeAt(int index) {
    int id = productIds_[index];
    if (_remove(id)) {
      notifyListeners();
    }
  }
}
