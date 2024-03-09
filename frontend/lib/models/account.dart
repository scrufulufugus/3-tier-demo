import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/middleware.dart';

class AccountModel extends ChangeNotifier {
  AccountModel();

  String? _token;

  bool? _admin;

  String? get token => _token;

  Future<AccountIn> get info async {
    final response = await http.get(
      Uri.parse('$endpoint/me'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return AccountIn.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to get account');
    }
  }

  bool get isAuthenticated {
    return _token != null;
  }

  bool get isAdmin {
    return _admin ?? false;
  }

  Future<bool> _login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$endpoint/token'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      encoding: Encoding.getByName('utf-8'),
      body: <String, String>{
        'username': username,
        'password': password,
      },
    );
    if (response.statusCode == 200) {
      _token = jsonDecode(response.body)['access_token'];
      return true;
    } else if (response.statusCode == 401) {
      return false;
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<bool> login(String username, String password) async {
    if (await _login(username, password)) {
      _admin = (await info).isAdmin;
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  void logout(BuildContext context) {
    context.go('/signout');
    _token = null;
    _admin = null;
    notifyListeners();
  }


  Future<String> update(AccountOut update, String currentPassword) async {
    if (!isAuthenticated) {
      return "You must be logged in to update your account";
    }
    if (!await _login((await info).username, currentPassword)) {
      return "Incorrect password";
    }

    final response = await http.patch(
      Uri.parse('$endpoint/me'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(update),
    );
    if (response.statusCode == 200) {
      if (update.password != null) {
        await _login(jsonDecode(response.body)['username'], update.password!);
      }
      notifyListeners();
      return "Account updated";
    } else {
      return "Failed to update account: ${response.reasonPhrase}";
    }
  }
}

class Account {
  final int? id;
  final String? username;
  final String? email;
  final String? password;
  final String? phone;
  final String? address;
  final bool? isAdmin;

  Account({
      required this.id,
      required this.username,
      required this.email,
      required this.password,
      required this.phone,
      required this.address,
      required this.isAdmin
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
        id: json['id'],
        username: json['username'],
        email: json['email'],
        password: json['password'],
        phone: json['phone'],
        address: json['address'],
        isAdmin: json['isAdmin']
    );
  }
}

class AccountIn extends Account {
  AccountIn({
      required int super.id,
      required String super.username,
      required String super.email,
      required String super.phone,
      required String super.address,
      required bool super.isAdmin
  }) : super(
      password: null,
  );

  @override
  int get id => super.id!;
  @override
  String get username => super.username!;
  @override
  String get email => super.email!;
  @override
  String get phone => super.phone!;
  @override
  String get address => super.address!;
  @override
  bool get isAdmin => super.isAdmin!;

  factory AccountIn.fromJson(Map<String, dynamic> json) {
    return AccountIn(
        id: json['id'],
        username: json['username'],
        email: json['email'],
        phone: json['phone'],
        address: json['address'],
        isAdmin: json['isAdmin']
    );
  }
}

class AccountOut extends Account {
  AccountOut({
      required int id,
      super.email,
      super.password,
      super.phone,
      super.address,
  }) : super(
      id: id,
      username: null,
      isAdmin: null
  );

  Map<String, dynamic> toJson() =>
      {
        'email': email,
        'password': password,
        'phone': phone,
        'address': address,
      }..removeWhere((key, value) => value == null);
}
