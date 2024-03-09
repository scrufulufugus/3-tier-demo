import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/middleware.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/catalog.dart';
import 'package:frontend/models/account.dart';

class CartModel extends Catalog {
  /// The current total price of all items.
  Future<double> get price async {
    double price = 0;
    for (var product in products) {
      price += (await product).price;
    }
    return price;
  }

  /// Adds [item] to cart. This and [removeAll] are the only ways to modify the
  /// cart from the outside.
  void add(int id) {
    productIds_.add(id);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  @override
  void remove(int id) {
    if(productIds_.remove(id)) {
      notifyListeners();
    }
  }

  @override
  void removeAt(int index) {
    productIds_.removeAt(index);
    notifyListeners();
  }

  /// Removes all items from the cart.
  void removeAll() {
    productIds_.clear();
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  // Purchase the items in the cart
  Future<PurchaseRecord> purchase(String token) async {
    final response = await http.post(
      Uri.parse('$endpoint/purchase'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(productIds_),
    );

    if (response.statusCode == 200) {
      PurchaseRecord record = PurchaseRecord.fromJson(jsonDecode(response.body));
      if (record.success) {
        removeAll();
      }
      return record;
    } else {
      throw Exception('Failed to purchase: ${response.reasonPhrase}');
    }
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
      failProd: json['fail_at'] as int?,
      products: (json['products'] as List).map((e) => e as int).toList(),
      message: json['message'] as String
    );
  }
}
