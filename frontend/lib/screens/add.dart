import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/catalog.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/productForm.dart';

class AddPage extends StatelessWidget {
  const AddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: Consumer<CatalogModel>(
        builder: (context, catalog, child) => ProductForm(
          onSubmit: (context, product) async {
            int newProduct = await catalog.add(product);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added product')),
              );
              context.pushReplacement('/admin/edit/$newProduct');
            }
          },
        ),
      ),
    );
  }
}
