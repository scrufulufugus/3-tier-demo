import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/cart.dart';
import 'package:frontend/models/account.dart';
import 'package:frontend/widgets/catalog.dart';
import 'package:frontend/widgets/header.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Material is a conceptual piece
    // of paper on which the UI appears.
    return Material(
      child: Scaffold(
        appBar: const Header(),
        body: Consumer<CartModel>(
          builder: (context, cart, child) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CartList(catalog: cart),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FutureBuilder<double>(
                      future: cart.price,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                              'Total: \$${snapshot.data!.toStringAsFixed(2)}');
                        } else {
                          return const CircularProgressIndicator();
                        }
                      }),
                  Consumer<AccountModel>(
                    builder: (context, account, child) => TextButton(
                      onPressed: account.isAuthenticated && cart.length > 0 ? () async {
                        PurchaseRecord result;
                        try {
                          result = await cart.purchase(account.token!);
                        } on Exception catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                          return;
                        }

                        String message = result.message;
                        if (!result.success && result.failProd != null) {
                          message += await cart.get(result.failProd!).then(
                                (product) => ' (${product.title})',
                              );
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        }
                      } : null,
                      child: const Text('BUY'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
