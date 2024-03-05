import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/models/account.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/catalog.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late Future<List<Future<Product>>> futureProducts;

  @override
  void initState() {
    super.initState();
    //futureProducts = fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    // Material is a conceptual piece
    // of paper on which the UI appears.
    return Material(
      child: Scaffold(
        appBar: const Header(),
        body: Consumer<AccountModel>(
          builder: (context, account, child) {
            if (!account.isAuthenticated) {
              return const Text('You are not logged in');
            }
            futureProducts = fetchProducts(token: account.token);
            return FutureBuilder<List<Future<Product>>>(
              future: futureProducts,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ProductList(products: snapshot.data!);
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }

                // By default, show a loading spinner.
                return const CircularProgressIndicator();
              },
            );
          },
        ),
      ),
    );
  }
}
