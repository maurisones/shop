import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/pages/products_overview_page.dart';

import '../components/auth.dart';
import 'auth_page.dart';

class AuthOrHomePage extends StatelessWidget {
  const AuthOrHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Auth auth = Provider.of(context, listen: false);
    return auth.isAuth ? ProductsOverviewPage() : AuthPage();
  }
}
