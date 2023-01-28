import 'dart:convert';
import 'dart:core';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop/models/cart_item.dart';
import 'package:shop/models/order.dart';

import '../utils/consts.dart';
import 'cart.dart';

class OrderList with ChangeNotifier {
  final String baseUrl = '${Consts.URL_BASE}/orders';

  List<Order> _items = [];

  List<Order> get items {
    return [..._items];
  }

  int get itensCount {
    return _items.length;
  }

  Future<void> loadOrders() async {
    final response = await http.get(Uri.parse('${baseUrl}.json'));
    print(jsonDecode(response.body));

    _items.clear();

    Map<String, dynamic> data = jsonDecode(response.body);
    if (data != null) {
      data.forEach((orderId, orderData) {
        _items.add(Order(
          id: orderId,
          date: DateTime.parse(orderData['date']),
          total: orderData['total'],
          products:
              (orderData['products'] as List<dynamic>).map((receivedCartItem) {
            return CartItem(
                id: receivedCartItem['id'],
                productId: receivedCartItem['productId'],
                name: receivedCartItem['name'],
                quantity: receivedCartItem['quantity'],
                price: receivedCartItem['price']);
          }).toList(),
        ));
      });
    }
    notifyListeners();
  }

  Future<void> addOrder(Cart cart) async {
    final DateTime date = DateTime.now();
    final response = await http.post(
      Uri.parse('${baseUrl}.json'),
      body: jsonEncode(
        {
          'total': cart.totalAmount,
          'date': date.toIso8601String(),
          'products': cart.itens.values
              .map((cartItem) => {
                    'id': cartItem.id,
                    'productId': cartItem.productId,
                    'name': cartItem.name,
                    'quantity': cartItem.quantity,
                    'price': cartItem.price,
                  })
              .toList()
        },
      ),
    );

    if (response.statusCode < 400) {
      final id = jsonDecode(response.body)['name'];
      _items.insert(
          0,
          Order(
            id: id,
            total: cart.totalAmount,
            products: cart.itens.values.toList(),
            date: date,
          ));
      notifyListeners();
    }
  }
}
