import 'package:flutter/material.dart';
import 'package:frontend/models/product.dart';

class CartModel extends ChangeNotifier implements ProductList {
  /// Internal, private state of the cart.
  final List<Product> _products = [];

  @override
  List<Product> get products => List.unmodifiable(_products);

  /// The current total price of all items.
  double get price {
    double price = 0;
    for (var product in _products) {
      price += product.price;
    }
    return price;
  }

  int get count => _products.length;

  /// Adds [item] to cart. This and [removeAll] are the only ways to modify the
  /// cart from the outside.
  void add(Product item) {
    _products.add(item);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  /// Removes all items from the cart.
  void removeAll() {
    _products.clear();
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}
