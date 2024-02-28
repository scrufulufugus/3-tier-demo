import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/cart.dart';
import 'package:frontend/widgets/catalog.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Material is a conceptual piece
    // of paper on which the UI appears.
    return Material(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(
            "Cart",
            style: Theme.of(context).primaryTextTheme.titleLarge,
          ),
        ),
        body: Consumer<CartModel>(
          builder: (context, cart, child) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CartList(products: cart.products),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Total: \$${cart.price}'),
                  TextButton(
                    child: const Text('BUY'),
                    onPressed: () {
                      cart.removeAll();
                    },
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
