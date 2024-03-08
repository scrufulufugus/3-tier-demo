import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/models/catalog.dart';
import 'package:frontend/models/account.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/catalog.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Material is a conceptual piece
    // of paper on which the UI appears.
    return Material(
      child: Scaffold(
        appBar: Header(
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(100.0),
            child: Row(
              children: [
                TextButton(
                  child: Text('Add Product',
                      style: Theme.of(context).primaryTextTheme.labelLarge),
                  onPressed: () {
                    context.push('/admin/add');
                  },
                ),
              ],
            ),
          ),
        ),
        body: Consumer<AccountModel>(
          builder: (context, account, child) {
            if (!account.isAuthenticated) {
              return const Text('You are not logged in');
            }
            return Consumer<CatalogModel>(
              builder: (context, catalog, child) =>
                  ProductList(catalog: catalog),
            );
          },
        ),
      ),
    );
  }
}
