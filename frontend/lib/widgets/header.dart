import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/cart.dart';
import 'package:frontend/models/account.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: TextButton(
        child: Text("Sumazon",
          style: Theme.of(context).primaryTextTheme.titleLarge
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/');
        },
      ),
      actions: [
        Consumer<AccountModel>(
            builder: (context, account, child) => PopupMenuButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'My Account',
            itemBuilder: (BuildContext context) {
              if (account.isAuthenticated) {
                return <PopupMenuEntry>[
                  PopupMenuItem(
                    child: const Text('My Account'),
                    onTap: () {
                      Navigator.pushNamed(context, '/account');
                    },
                  ),
                  if (account.info.isAdmin)
                    PopupMenuItem(
                      child: const Text('Admin Panel'),
                      onTap: () {
                        Navigator.pushNamed(context, '/admin');
                      },
                    ),
                  PopupMenuItem(
                    child: const Text('Sign Out'),
                    onTap: () {
                      account.logout();
                    },
                  ),
                ];
              } else {
                return <PopupMenuEntry>[
                  PopupMenuItem(
                    child: const Text('Sign In'),
                    onTap: () {
                      // Navigate to sign in page
                      Navigator.pushNamed(context, '/account/login');
                    },
                  ),
                  const PopupMenuItem(
                    enabled: false,
                    child: Text('Register'),
                  ),
                ];
              }
            }),
          ),
        Consumer<CartModel>(
            builder: (context, cart, child) => Badge.count(
                count: cart.length,
                child: IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    tooltip: 'Cart',
                    onPressed: () {
                      Navigator.pushNamed(context, '/cart');
                    },
              ))),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
