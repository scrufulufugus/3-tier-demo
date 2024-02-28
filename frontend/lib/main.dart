import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/catalog.dart';
import 'package:frontend/models/cart.dart';
import 'package:frontend/screens/home.dart';
import 'package:frontend/screens/cart.dart';
import 'package:frontend/screens/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CatalogModel()),
        ChangeNotifierProvider(create: (context) => CartModel()),
      ],
      child: MaterialApp(
      title: 'Sumazon',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => const HomePage(),
        '/login': (BuildContext context) => const LoginPage(),
        '/cart': (BuildContext context) => const CartPage(),
      }
    ),
  );
  }
}
