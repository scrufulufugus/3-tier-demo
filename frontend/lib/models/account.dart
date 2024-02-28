import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountModel extends ChangeNotifier {
  AccountModel();

  Account? _account;

  bool get isAuthenticated {
    return _account != null;
  }

  bool get isAdmin {
    return _account?.isAdmin ?? false;
  }

  void login(String username, String password) {
    // TODO: Make a request to the server to login
    _account = Account(1, username, "test@example.com", password,
        "1234567890", "1234 Elm St", true);
    notifyListeners();
  }

  void logout(BuildContext context) {
    context.go('/signout');
    _account = null;
    notifyListeners();
  }

  Account get info {
    return Account(
        _account?.id ?? 0,
        _account?.username ?? '',
        _account?.email ?? '',
        '',
        _account?.phone ?? '',
        _account?.address ?? '',
        false
    );
  }

  String updateAccount(String? email, String? password,
      String? phone, String? address, String currentPassword) {
    if (_account == null) {
      return "You must be logged in to update your account";
    }

    Account updated = Account(
        _account!.id,
        _account!.username,
        email ?? _account!.email,
        password ?? _account!.password,
        phone ?? _account!.phone,
        address ?? _account!.address,
        _account!.isAdmin);

    // TODO: Make a request to the server to update the account
    _account = updated;
    notifyListeners();
    return "Account updated";
  }
}

class Account {
  Account(this.id, this.username, this.email, this.password, this.phone,
      this.address, this.isAdmin);
  final int id;
  final String username;
  final String email;
  final String password;
  final String phone;
  final String address;
  final bool isAdmin;
}
