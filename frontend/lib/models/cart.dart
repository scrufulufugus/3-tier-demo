import 'package:flutter/material.dart';
import 'package:frontend/models/catalog.dart';
import 'package:frontend/models/account.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartModel extends Catalog {
  /// The current total price of all items.
  Future<double> get price async {
    double price = 0;
    for (var product in products) {
      price += (await product).price;
    }
    return price;
  }

  int get length => productIds.length;

  /// Adds [item] to cart. This and [removeAll] are the only ways to modify the
  /// cart from the outside.
  @override
  void add(int id) {
    productIds.add(id);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  @override
  void remove(int id) {
    if(productIds.remove(id)) {
      notifyListeners();
    }
  }

  @override
  void removeAt(int index) {
    productIds.removeAt(index);
    notifyListeners();
  }

  /// Removes all items from the cart.
  void removeAll() {
    productIds.clear();
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  // Purchase the items in the cart
  Future<String> purchase(BuildContext context) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/purchase'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${Provider.of<AccountModel>(context, listen: false).token}',
      },
      body: jsonEncode(productIds),
    );

    if (response.statusCode == 200) {
      PurchaseRecord record = PurchaseRecord.fromJson(jsonDecode(response.body));
      if (record.success) {
        removeAll();
      }
      return record.message;
    }
    return 'Error: ${response.reasonPhrase}';
  }
}

class PurchaseRecord {
  final int id;
  final bool success;
  final int? failProd;
  final List<int> products;
  final String message;

  const PurchaseRecord({
      required this.id,
      required this.success,
      this.failProd,
      required this.products,
      required this.message
  });

  factory PurchaseRecord.fromJson(Map<String, dynamic> json) {
    return PurchaseRecord(
      id: json['id'] as int,
      success: json['success'] as bool,
      failProd: json['failProd'] as int?,
      products: (json['products'] as List).map((e) => e as int).toList(),
      message: json['message'] as String
    );
  }
}
