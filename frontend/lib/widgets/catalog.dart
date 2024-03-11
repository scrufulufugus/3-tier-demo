import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/models/catalog.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/models/cart.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({required this.catalog, super.key});
  final CatalogList catalog;

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      itemCount: catalog.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 500.0,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (BuildContext context, int index) {
        return Card(
          child: FutureBuilder<Product>(
            future: catalog[index],
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Product product = snapshot.data!;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  //mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, left: 8.0, right: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, left: 8.0, right: 8.0),
                      child: Text(
                        product.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, left: 8.0, right: 8.0),
                      child: Text(product.description),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, left: 8.0, right: 8.0),
                      child: Text(currencyFormater.format(product.price * .01)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          child: const Text('ADD TO CART'),
                          onPressed: () {
                            Provider.of<CartModel>(context, listen: false)
                                .add(product.id);
                          },
                        ),
                      ],
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return const CircularProgressIndicator();
            },
          ),
        );
      },
    );
  }
}

class ProductList extends StatelessWidget {
  const ProductList({required this.catalog, super.key});
  final CatalogList catalog;

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: catalog.length,
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      itemBuilder: (BuildContext context, int index) {
        return FutureBuilder<Product>(
          future: catalog[index],
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Product product = snapshot.data!;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(product.title),
                  ),
                  Expanded(
                    flex: 8,
                    child: Text(product.description),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(currencyFormater.format(product.price * .01)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Stock: ${product.stock}'),
                  ),
                  Expanded(
                    flex: 4,
                    child: OverflowBar(
                      alignment: MainAxisAlignment.end,
                      overflowAlignment: OverflowBarAlignment.center,
                      children: [
                        TextButton(
                          child: const Text('EDIT'),
                          onPressed: () {
                            context.push("/admin/edit/${product.id}");
                          },
                        ),
                        TextButton(
                          child: const Text('DELETE'),
                          onPressed: () {
                            catalog.removeAt(index);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            return const CircularProgressIndicator();
          },
        );
      },
    );
  }
}

class CartList extends StatelessWidget {
  const CartList({required this.catalog, super.key});
  final Catalog catalog;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.vertical,
      shrinkWrap: true, // Fixes unbloud size error
      itemCount: catalog.length,
      padding: const EdgeInsets.all(8.0),
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      itemBuilder: (BuildContext context, int index) {
        return FutureBuilder<Product>(
          future: catalog[index],
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Product product = snapshot.data!;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 10,
                    child: Text(product.title),
                  ),
                  Expanded(
                    flex: 10,
                    child: Text(currencyFormater.format(product.price * .01)),
                  ),
                  Expanded(
                    flex: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: const Text('REMOVE'),
                          onPressed: () {
                            catalog.removeAt(index);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 10,
                    child: Text('${snapshot.error}'),
                  ),
                  Expanded(
                    flex: 10,
                    child: Text(currencyFormater.format(0)),
                  ),
                  Expanded(
                    flex: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: const Text('REMOVE'),
                          onPressed: () {
                            catalog.removeAt(index);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const CircularProgressIndicator();
          },
        );
      },
    );
  }
}
