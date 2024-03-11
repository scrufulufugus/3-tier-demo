import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/catalog.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/productForm.dart';

class EditPage extends StatelessWidget {
  const EditPage({required this.productId, super.key});
  final int productId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: Consumer<CatalogModel>(
        builder: (context, catalog, child) => FutureBuilder<Product>(
          future: catalog.get(productId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ProductForm(
                product: snapshot.data,
                onSubmit: (context, product) {
                  // TODO: Make POST route a PATCH route
                  // String? nullIfUnchanged(String? value, String? original) {
                  //   if (value == null || value.isEmpty) {
                  //     return null;
                  //   }
                  //   return value == original ? null : value;
                  // }
                  try {
                    catalog.update(productId, product);
                  } on Exception catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                    return;
                  }

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Updated product')),
                    );
                  }
                },
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
