import 'package:flutter/foundation.dart';
import 'package:shop/data/dummy_data.dart';
import 'package:shop/models/product.dart';

class ProductList with ChangeNotifier {
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

  void addProduct(Product product) {
    int index = _items.indexWhere((element) => element.id == product.id);
    if (index == -1) {
      _items.add(product);
    } else {
      _items[index] = product;
    }
    notifyListeners();
  }

  void removeProduct(String productId) {
    int index = _items.indexWhere((element) => element.id == productId);
    _items.removeAt(index);
    notifyListeners();
  }
}
