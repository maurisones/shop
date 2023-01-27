import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop/data/dummy_data.dart';
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/models/product.dart';

class ProductList with ChangeNotifier {
  final String baseUrl =
      'https://teste-1a75c-default-rtdb.firebaseio.com/teste';
  //List<Product> _items = dummyProducts;
  List<Product> _items = [];

  bool _showFavoriteOnly = false;

  Future<void> loadProducts() async {
    final response = await http.get(Uri.parse('${baseUrl}.json'));
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
        Uri.parse('${baseUrl}.json'),
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
        Uri.parse('${baseUrl}/${product.id}.json'),
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
    final response =
        await http.delete(Uri.parse('${baseUrl}/${productId}.json'));

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
}
