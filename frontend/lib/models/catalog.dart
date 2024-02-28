import 'package:flutter/material.dart';
import 'package:frontend/models/product.dart';

class CatalogModel extends ChangeNotifier implements ProductList {
  CatalogModel() {
    // TODO: Lazy load from server
    initCatalog(List<Product>.generate(
        51,
        (int index) => Product(
            index,
            'Item $index',
            'Description of item $index',
            index * 3.0,
            'https://via.placeholder.com/150')));
  }

  /// Internal, private state of the cart.
  final List<Product> _products = [];

  String? _searchQuery;

  /// Get a list of items in the catalog filtered by the search query.
  @override
  List<Product> get products {
    if (_searchQuery == null || _searchQuery!.isEmpty) {
      return List.unmodifiable(_products);
    } else {
      return _products.where((product) {
        return product.title
            .toLowerCase()
            .contains(_searchQuery!.toLowerCase());
      }).toList();
    }
  }

  // Apply a search query to the catalog
  void filter(String query) {
    // FIXME: Remove print
    print("Searching $query");
    _searchQuery = query;
    notifyListeners();
  }

  // Clear the search query
  void clearFilter() {
    _searchQuery = null;
    notifyListeners();
  }

  // FIXME: Remove this
  void initCatalog(List<Product> products) {
    _products.clear();
    _products.addAll(products);
  }

  // Update the catalog from the server
  void updateCatalog(List<Product> products) {
    _products.clear();
    _products.addAll(products);
    notifyListeners();
  }
}
