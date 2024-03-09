import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/models/catalog.dart';
import 'package:frontend/models/account.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/catalog.dart';
import 'package:frontend/widgets/search.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => AdminPageState();
}

class AdminPageState extends State<AdminPage> {
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
        body: CustomScrollView(
          slivers: [
            SliverHeader(
              bottom: SearchAppBar(
                searchCallback: _runFilter,
                addCallback: () {
                  context.push('/admin/add');
                },
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: filterItems?.isNotEmpty ?? true
                  ? Consumer<AccountModel>(
                      builder: (context, account, child) {
                        if (!account.isAuthenticated) {
                          return const SliverToBoxAdapter(
                            child: Text(
                              'You are not logged in',
                              style: TextStyle(fontSize: 24),
                            ),
                          );
                        }
                        return Consumer<CatalogModel>(
                          builder: (context, catalog, child) =>
                              ProductList(catalog: catalog.products),
                        );
                      },
                    )
                  : const SliverToBoxAdapter(
                      child: Text(
                        'No results found',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
