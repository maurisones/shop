import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop/data/dummy_data.dart';
import 'package:shop/models/product.dart';

class ProductList with ChangeNotifier {
  final String urlBase = 'https://teste-1a75c-default-rtdb.firebaseio.com';
  List<Product> _items = dummyProducts;

  bool _showFavoriteOnly = false;

  List<Product> get items {
    if (_showFavoriteOnly) {
      return _items.where((product) => product.isFavorite).toList();
    }
    return [..._items];
  }

  void showFavoriteOnly() {
    _showFavoriteOnly = true;
    notifyListeners();
  }

  void showAll() {
    _showFavoriteOnly = false;
    notifyListeners();
  }

  // função não tem return pois ela retorna um Feature<void>
  Future<void> addProduct(Product product) async {
    int index = _items.indexWhere((element) => element.id == product.id);
    if (index == -1) {
      final response = await http.post(
        Uri.parse('${urlBase}/teste.json'),
        body: jsonEncode({
          "name": product.name,
          "description": product.description,
          "price": product.price,
          "imageUrl": product.imageUrl,
          "isFavorite": product.isFavorite,
        }),
      );

      final id = jsonDecode(response.body)['name'].toString();
      _items.add(Product(
        id: id,
        name: product.name,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      ));
      notifyListeners();
    } else {
      print(product.id);
      final response = await http.put(
        Uri.parse('${urlBase}/teste.json/${product.id}'),
        body: jsonEncode({
          "name": product.name,
          "description": product.description,
          "price": product.price,
          "imageUrl": product.imageUrl,
          "isFavorite": product.isFavorite,
        }),
      );

      print(response.statusCode);
      _items[index] = product;
      notifyListeners();
    }
  }

  void removeProduct(String productId) {
    int index = _items.indexWhere((element) => element.id == productId);
    _items.removeAt(index);
    notifyListeners();
  }
}
