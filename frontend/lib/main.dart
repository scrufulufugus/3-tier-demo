import 'package:flutter/material.dart';
import 'package:frontend/models/catalog.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/cart.dart';
import 'package:frontend/models/account.dart';
import 'package:frontend/screens/home.dart';
import 'package:frontend/screens/cart.dart';
import 'package:frontend/screens/login.dart';
import 'package:frontend/screens/account.dart';
import 'package:frontend/screens/admin.dart';
import 'package:frontend/screens/edit.dart';
import 'package:frontend/screens/add.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminPage(),
    ),
    GoRoute(
      path: '/admin/add',
      builder: (context, state) => const AddPage(),
    ),
    GoRoute(
      path: '/admin/edit/:id',
      builder: (context, state) => EditPage(productId: int.parse(state.pathParameters['id'] ?? "1")),
    ),
    GoRoute(
      path: '/account',
      builder: (context, state) => const AccountPage(),
    ),
    GoRoute(
      path: '/account/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartPage(),
    ),
    GoRoute(
      path: '/signout',
      builder: (context, state) => const LoginPage(),
    ),
  ],
);

void main() {
  Intl.defaultLocale = 'en_US';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartModel()),
        ChangeNotifierProvider(create: (context) => AccountModel()),
        ChangeNotifierProxyProvider<AccountModel, CatalogModel>(
          create: (_) => CatalogModel(),
          update: (_, account, previous) => previous!..token = account.token,
        ),
      ],
      child: MaterialApp.router(
          title: 'Sumazon',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          routerConfig: _router,
      ),
    );
  }
}
