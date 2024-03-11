import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/models/cart.dart';
import 'package:frontend/models/account.dart';
import 'package:frontend/models/catalog.dart';

class AccountMenu extends StatelessWidget {
  const AccountMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountModel>(
      builder: (context, account, child) => PopupMenuButton(
        icon: const Icon(Icons.account_circle),
        iconColor: Theme.of(context).colorScheme.onPrimary,
        tooltip: 'My Account',
        itemBuilder: (BuildContext context) {
          if (account.isAuthenticated) {
            return <PopupMenuEntry>[
              PopupMenuItem(
                child: const Text('My Account'),
                onTap: () {
                  context.push('/account');
                },
              ),
              if (account.isAdmin)
                PopupMenuItem(
                  child: const Text('Admin Panel'),
                  onTap: () {
                    context.push('/admin');
                  },
                ),
              PopupMenuItem(
                child: const Text('Sign Out'),
                onTap: () {
                  account.logout(context);
                },
              ),
            ];
          } else {
            return <PopupMenuEntry>[
              PopupMenuItem(
                child: const Text('Sign In'),
                onTap: () {
                  // Navigate to sign in page
                  context.push('/account/login');
                },
              ),
              const PopupMenuItem(
                enabled: false,
                child: Text('Register'),
              ),
            ];
          }
        },
      ),
    );
  }
}

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: TextButton(
        child: Text("Sumazon",
            style: Theme.of(context).primaryTextTheme.titleLarge),
        onPressed: () {
          context.push('/');
        },
      ),
      leading: IconButton(
        icon: const Icon(Icons.refresh),
        color: Theme.of(context).colorScheme.onPrimary,
        tooltip: 'Refresh',
        onPressed: () {
          Provider.of<CatalogModel>(context, listen: false).forceRefresh();
        },
      ),
      actions: [
        const AccountMenu(),
        Consumer<CartModel>(
          builder: (context, cart, child) => Badge.count(
            count: cart.length,
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              color: Theme.of(context).colorScheme.onPrimary,
              tooltip: 'Cart',
              onPressed: () {
                context.push('/cart');
              },
            ),
          ),
        ),
        const SizedBox(width: 24),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SliverHeader extends StatelessWidget implements PreferredSizeWidget {
  const SliverHeader({super.key, this.bottom});
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      snap: false,
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: TextButton(
        child: Text("Sumazon",
            style: Theme.of(context).primaryTextTheme.titleLarge),
        onPressed: () {
          context.push('/');
        },
      ),
      leading: IconButton(
        icon: const Icon(Icons.refresh),
        color: Theme.of(context).colorScheme.onPrimary,
        tooltip: 'Refresh',
        onPressed: () {
          Provider.of<CatalogModel>(context, listen: false).forceRefresh();
        },
      ),
      bottom: bottom,
      actions: [
        const AccountMenu(),
        Consumer<CartModel>(
          builder: (context, cart, child) => Badge.count(
            count: cart.length,
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              color: Theme.of(context).colorScheme.onPrimary,
              tooltip: 'Cart',
              onPressed: () {
                context.push('/cart');
              },
            ),
          ),
        ),
        const SizedBox(width: 24),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
