import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/auth.dart';
import 'package:shop/models/order_list.dart';
import 'package:shop/pages/auth_or_home.dart';
import 'package:shop/pages/auth_page.dart';
import 'package:shop/pages/cart_page.dart';
import 'package:shop/pages/orders_page.dart';
import 'package:shop/pages/product_form_page.dart';
import 'package:shop/pages/product_page.dart';
import 'package:shop/pages/products_overview_page.dart';
import 'package:shop/models/product_list.dart';
import 'package:shop/utils/app_routes.dart';

import 'models/cart.dart';
import 'pages/product_detail_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, ProductList>(
          create: (_) => ProductList('', []),
          update: (context, auth, previous) =>
              ProductList(auth.token ?? '', previous?.items ?? []),
        ),
        ChangeNotifierProvider(
          create: (_) => Cart(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderList(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.deepOrange,
          fontFamily: 'Lato',
        ),
        //home: ProductsOverviewPage(),
        debugShowCheckedModeBanner: false,
        routes: {
          AppRoutes.AUTH_OR_HOME: (context) => AuthOrHomePage(),
          AppRoutes.PRODUCT_DETAIL: (context) => ProductDetailPage(),
          AppRoutes.CART: (context) => CartPage(),
          AppRoutes.ORDERS: (context) => OrdersPage(),
          AppRoutes.PRODUCTS: (context) => ProductPage(),
          AppRoutes.PRODUCTS_FORM: (context) => ProductFormPage(),
        },
      ),
    );
  }
}
