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
                  String? nullIfUnchanged(String? value, String? original) {
                    if (value == null || value.isEmpty) {
                      return null;
                    }
                    return value == original ? null : value;
                  }

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Saving changes')),
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
