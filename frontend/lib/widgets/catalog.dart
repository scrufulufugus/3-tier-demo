import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/models/cart.dart';

// TODO: Make ProductDisplay an interface that ProductGrid and ProductList implement

class ProductGrid extends StatelessWidget {
  const ProductGrid({required this.products, super.key});
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        itemCount: products.length,
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  products[index].imageUrl,
                  fit: BoxFit.cover,
                  height: 100,
                ),
                Text(products[index].title),
                Text(products[index].description),
                Text('\$${products[index].price}'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      child: const Text('ADD TO CART'),
                      onPressed: () {
                        Provider.of<CartModel>(context, listen: false).add(products[index]);
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}

class ProductList extends ProductGrid {
  const ProductList({required super.products, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: products.length,
        padding: const EdgeInsets.all(8.0),
        itemBuilder: (BuildContext context, int index) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(products[index].title),
              Text(products[index].description),
              Text('\$${products[index].price}'),
              Text('Stock: ${products[index].stock}'),
              TextButton(
                child: const Text('DELETE'),
                onPressed: () {
                  // FIXME: Dosn't update the UI
                  products.removeAt(index);
                },
              ),
            ],
          );
        });
  }
}

class CartList extends ProductGrid {
  const CartList({required super.products, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true, // Fixes unbloud size error
        itemCount: products.length,
        padding: const EdgeInsets.all(8.0),
        itemBuilder: (BuildContext context, int index) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(products[index].title),
              Text('\$${products[index].price}'),
              TextButton(
                child: const Text('DELETE'),
                onPressed: () {
                  Provider.of<CartModel>(context, listen: false).remove(index);
                },
              ),
            ],
          );
        });
  }
}
