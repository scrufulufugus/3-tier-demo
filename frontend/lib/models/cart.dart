import 'package:flutter/material.dart';
import 'package:frontend/models/product.dart';

class CartModel extends ChangeNotifier {
  /// Internal, private state of the cart.
  final List<int> _productIds = [];

  List<Future<Product>> get products => _productIds.map((id) => fetchProduct(id)).toList();

  // void updateList() async {
  //   _productIds.clear();
  //   _productIds.addAll(await fetchProductIds());
  //   notifyListeners();
  // }

  /// The current total price of all items.
  Future<double> get price async {
    double price = 0;
    for (var product in products) {
      price += (await product).price;
    }
    return price;
  }

  int get length => _productIds.length;

  /// Adds [item] to cart. This and [removeAll] are the only ways to modify the
  /// cart from the outside.
  void add(int id) {
    _productIds.add(id);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void remove(int id) {
    if(_productIds.remove(id)) {
      notifyListeners();
    }
  }

  void removeAt(int index) {
    _productIds.removeAt(index);
    notifyListeners();
  }

  /// Removes all items from the cart.
  void removeAll() {
    _productIds.clear();
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}
