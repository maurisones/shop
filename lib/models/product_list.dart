import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop/data/dummy_data.dart';
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/models/product.dart';
import 'package:shop/utils/consts.dart';

class ProductList with ChangeNotifier {
  final String baseUrlProducts = '${Consts.URL_BASE}/products';

  String _token;
  List<Product> _items = [];
  String _uid;

  bool _showFavoriteOnly = false;

  ProductList([this._token = '', this._items = const [], this._uid = '']);

  Future<void> loadProducts() async {
    final response =
        await http.get(Uri.parse('${baseUrlProducts}.json?auth=${_token}'));
    print(jsonDecode(response.body));

    _items.clear();

    Map<String, dynamic> data = jsonDecode(response.body);
    if (data != null) {
      data.forEach((productId, productData) {
        _items.add(Product(
          id: productId,
          name: productData['name'],
          description: productData['description'],
          price: productData['price'] as double,
          imageUrl: productData['imageUrl'],
          isFavorite: productData['isFavorite'],
        ));
      });
    }

    final responseFav = await http.get(
      Uri.parse('${Consts.URL_BASE}/userFavorites/${_uid}.json?auth=${_token}'),
    );

    print(responseFav.body);

    Map<String, dynamic> dataFav = jsonDecode(responseFav.body);
    dataFav.forEach((producId, value) {
      int index =
          _items.indexWhere((element) => element.id == producId).toInt();
      if (index >= 0) {
        _items[index].isFavorite = dataFav[producId];
      }
    });

    notifyListeners();
  }

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
        Uri.parse('${baseUrlProducts}.json?auth=${_token}'),
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
      final response = await http.patch(
        Uri.parse('${baseUrlProducts}/${product.id}.json?auth=${_token}'),
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

  Future<void> removeProduct(String productId) async {
    final response = await http.delete(
        Uri.parse('${baseUrlProducts}/${productId}.json?auth=${_token}'));

    if (response.statusCode == 200) {
      int index = _items.indexWhere((element) => element.id == productId);
      _items.removeAt(index);
    } else {
      throw HttpException(
          msg: 'Não foi possível excluir o produto!',
          statusCode: response.statusCode);
    }

    notifyListeners();
  }

  Future<void> addProductUserFavorite(Product product) async {
    final response = await http.patch(
        Uri.parse(
            '${Consts.URL_BASE}/userFavorites/${_uid}.json?auth=${_token}'),
        body: jsonEncode({product.id: product.isFavorite}));

    print(response.body);
    notifyListeners();
  }
}
