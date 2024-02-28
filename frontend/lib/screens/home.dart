import 'package:flutter/material.dart';
import 'package:frontend/models/catalog.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/catalog.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Material is a conceptual piece
    // of paper on which the UI appears.
    return Material(
      child: HeaderWrapper(
        body: Consumer<CatalogModel>(
            builder: (context, catalog, child) =>
                ProductGrid(products: catalog.products)),
      ),
    );
  }
}
