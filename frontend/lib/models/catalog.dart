import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:frontend/middleware.dart';
import 'package:frontend/models/product.dart';

class CatalogList extends UnmodifiableListView<Future<Product>> {
  CatalogList(super.source, this.catalog);
  CatalogList.fromIds(List<int> ids, this.catalog)
      : super(ids.map((id) => catalog.get(id)).toList());
  final Catalog catalog;

  @override
  bool remove(Object? element) {
    if (element is int) {
      catalog.remove(element);
      return true;
    }
    throw UnimplementedError();
  }

  @override
  Future<Product> removeAt(int index) async {
    Future<Product> prod = super[index];
    catalog.remove((await prod).id);
    return prod;
  }
}

abstract class Catalog extends ChangeNotifier {
  @protected
  String? token_;
  @protected
  final List<int> productIds_ = [];
  @protected
  final Map<int, Future<Product>> prodCache_ = {};

  @protected
  void dropCache_() => prodCache_.clear();
  @protected
  void dropCacheItem_(int id) => prodCache_.remove(id);

  Future<Product> get(int id) => prodCache_.putIfAbsent(id, () => fetchProduct_(id));
  CatalogList get products => CatalogList.fromIds(productIds_, this);
  Future<Product> operator [](int index) => get(productIds_[index]);
  int get length => productIds_.length;

  void remove(int id);
  void removeAt(int index);

  @protected
  Future<Product> fetchProduct_(int id) async {
    final response = await http.get(
      Uri.parse('$endpoint/product/$id'),
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
      Uri.parse('$endpoint/products'),
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

  void forceRefresh() async {
    List<int> newIds = await fetchProductIds_();
    dropCache_();
    productIds_..clear()..addAll(newIds);
    notifyListeners();
  }

  void updateList() async {
    List<int> newIds = await fetchProductIds_();
    dropCache_();
    if (const DeepCollectionEquality.unordered().equals(productIds_, newIds)) {
      //notifyListeners(); // Maybe?
      return;
    }
    productIds_..clear()..addAll(newIds);
    notifyListeners();
  }

  void dropCache() {
    dropCache_();
    notifyListeners();
  }

  void dropCacheItem(int id) {
    dropCacheItem_(id);
    notifyListeners();
  }

  Future<CatalogList> filterBy(bool Function(Product) predicate) async {
    List<Product> unwrappedProducts = await Future.wait(products);
    return CatalogList.fromIds(
      unwrappedProducts.where(predicate).map((prod) => prod.id).toList(),
      this,
    );
  }

  Future<int> add(ProductBase newProduct) async {
    if (token_ == null) {
      throw Exception('Cannot add to catalog without a token');
    }
    final response = await http.post(
      Uri.parse('$endpoint/product'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token_',
      },
      body: jsonEncode(newProduct.toJson()),
    );

    if (response.statusCode == 200) {
      updateList();
      Product result = Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      return result.id;
    } else {
      throw Exception('Failed to add product');
    }
  }

  void update(int id, ProductBase update) async {
    if (token_ == null) {
      throw Exception('Cannot update catalog without a token');
    }
    final response = await http.post(
      Uri.parse('$endpoint/product/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token_',
      },
      body: jsonEncode(update.toJson()),
    );

    if (response.statusCode == 200) {
      dropCacheItem(id);
    } else {
      throw Exception('Failed to update product');
    }
  }

  void _remove(int id) async {
    if (token_ == null) {
      throw Exception('Cannot remove from catalog without a token');
    }
    final response = await http.delete(
      Uri.parse('$endpoint/product/$id'),
      headers: <String, String>{
        'Authorization': 'Bearer $token_',
      },
    );

    if (response.statusCode == 200) {
      updateList();
    } else {
      throw Exception('Failed to delete product');
    }
  }

  @override
  void remove(int id) {
    _remove(id);
  }

  @override
  void removeAt(int index) {
    int id = productIds_[index];
    _remove(id);
  }
}
