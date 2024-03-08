import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/catalog.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/catalog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  CatalogList? filterItems;

  @override
  void initState() {
    super.initState();
  }

  void _runFilter(String enteredKeyword) async {
    if (enteredKeyword.isEmpty) {
      setState(() {
        filterItems =
            Provider.of<CatalogModel>(context, listen: false).products;
      });
      return;
    }

    final CatalogList result =
        await Provider.of<CatalogModel>(context, listen: false).filterBy(
      (product) => product
          .toString()
          .toLowerCase()
          .contains(enteredKeyword.toLowerCase()),
    );
    setState(() {
      filterItems = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Material is a conceptual piece
    // of paper on which the UI appears.
    return Material(
      child: Scaffold(
        appBar: const Header(),
        body: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            TextField(
              onChanged: (value) => _runFilter(value),
              decoration: const InputDecoration(
                  labelText: 'Search', suffixIcon: Icon(Icons.search)),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: filterItems?.isNotEmpty ?? true
                  ? Consumer<CatalogModel>(
                      builder: (context, catalog, child) =>
                          ProductGrid(catalog: filterItems ?? catalog.products),
                    )
                  : const Text(
                      'No results found',
                      style: TextStyle(fontSize: 24),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
