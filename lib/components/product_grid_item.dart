import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/auth.dart';
import 'package:shop/models/product_list.dart';
import 'package:shop/pages/product_detail_page.dart';
import 'package:shop/utils/app_routes.dart';

import '../models/cart.dart';
import '../models/product.dart';

class ProductGridItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Product product = Provider.of<Product>(context, listen: true);
    final Cart cart = Provider.of<Cart>(context, listen: true);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
          onTap: () {
            Navigator.of(context).pushNamed(
              AppRoutes.PRODUCT_DETAIL,
              arguments: product,
            );
          },
        ),
        footer: GridTileBar(
          leading: IconButton(
            onPressed: () {
              product.toggleFavorite();
              Provider.of<ProductList>(context, listen: false)
                  .addProductUserFavorite(product);
            },
            icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border),
            color: Theme.of(context).accentColor,
          ),
          backgroundColor: Colors.black54,
          title: Text(
            product.name,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              cart.addItem(product);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Produto adicionado com sucesso!'),
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'Desfazer',
                      onPressed: () {
                        cart.removeQuantity(product.id);
                      },
                    )),
              );
              print('${cart.itemsCount} - ${cart.totalAmount}');
            },
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}
