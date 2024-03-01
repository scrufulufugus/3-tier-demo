import 'package:flutter/material.dart';
import 'package:frontend/models/product.dart';

class CatalogModel extends ChangeNotifier implements ProductList {
  CatalogModel() {
    // TODO: Lazy load from server
    _products.addAll(List<Product>.generate(
        51,
        (int index) => Product(
            id: index,
            title: 'Item $index',
            description: 'Description of item $index',
            price: index * 3.0,
            imageUrl: 'https://via.placeholder.com/150')));
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

  @override
  void add(Product item) {
    _products.add(item);
    notifyListeners();
  }

  @override
  void remove(int index) {
    _products.removeAt(index);
    notifyListeners();
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

  // Update the catalog from the server
  void updateCatalog(List<Product> products) {
    _products.clear();
    _products.addAll(products);
    notifyListeners();
  }
}
