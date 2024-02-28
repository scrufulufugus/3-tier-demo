import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/catalog.dart';
import 'package:frontend/models/cart.dart';
import 'package:frontend/state.dart';

class HeaderWrapper extends StatelessWidget {
  const HeaderWrapper({required this.body, super.key});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        title: Text(
          "Sumazon",
          style: Theme.of(context).primaryTextTheme.titleLarge,
        ),
      ),
      body: body,
    );
  }
}

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({required this.title, super.key});

  // Fields in a Widget subclass are always marked "final".

  final Widget title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: Row(
        children: [
          title,
          const Expanded(child: SearchBarApp()),
        ],
      ),
      actions: [
        PopupMenuButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'My Account',
            itemBuilder: (BuildContext context) {
              if (isAuthenticated) {
                return <PopupMenuEntry>[
                  const PopupMenuItem(
                    child: Text('My Account'),
                  ),
                  PopupMenuItem(
                    child: const Text('Sign Out'),
                    onTap: () {
                      logout();
                    },
                  ),
                ];
              } else {
                return <PopupMenuEntry>[
                  PopupMenuItem(
                    child: const Text('Sign In'),
                    onTap: () {
                      // Navigate to sign in page
                      Navigator.pushNamed(context, '/login');
                    },
                  ),
                  const PopupMenuItem(
                    child: Text('Register'),
                  ),
                ];
              }
            }),
        Consumer<CartModel>(
          builder: (context, cart, child) => Badge.count(
            count: cart.count,
            child: const IconButton(
              icon: Icon(Icons.shopping_cart),
              tooltip: 'Cart',
              onPressed: null, // null disables the button
            )
          )
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SearchBarApp extends StatefulWidget {
  const SearchBarApp({super.key});

  @override
  State<SearchBarApp> createState() => _SearchBarAppState();
}

class _SearchBarAppState extends State<SearchBarApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SearchAnchor(
          builder: (BuildContext context, SearchController controller) {
        return SearchBar(
          controller: controller,
          padding: const MaterialStatePropertyAll<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 16.0)),
          onTap: () {
            controller.openView();
          },
          onChanged: (_) {
            controller.openView();
          },
          onSubmitted: (entry) {
            Provider.of<CatalogModel>(context, listen: false).filter(entry);
          },
          leading: const Icon(Icons.search),
        );
      }, suggestionsBuilder:
              (BuildContext context, SearchController controller) {
        return List<ListTile>.generate(5, (int index) {
          final String item = 'item $index';
          return ListTile(
            title: Text(item),
            onTap: () {
              setState(() {
                controller.closeView(item);
              });
            },
          );
        });
      }),
    );
  }
}
