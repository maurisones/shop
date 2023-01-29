import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/exceptions/auth_exception.dart';

class Auth with ChangeNotifier {
  static const _authUrlSignUp =
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyAzU3MwM2X9KUlMmf-aAhvqkm8WkBeH8VI';
  static const _authUrlSignIn =
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyAzU3MwM2X9KUlMmf-aAhvqkm8WkBeH8VI';

  String? _token;
  String? _email;
  String? _uid;
  DateTime? _expireDate;

  bool get isAuth {
    final isValid = _expireDate?.isAfter(DateTime.now()) ?? false;
    print(_token != null && isValid);
    return _token != null && isValid;
  }

  String? get token {
    return isAuth ? _token : null;
  }

  String? get email {
    return isAuth ? _email : null;
  }

  String? get uid {
    return isAuth ? _uid : null;
  }

  DateTime? get expireDate {
    return isAuth ? _expireDate : null;
  }

  Future<void> signUp(String email, String password) async {
    final response = await http.post(
      Uri.parse(_authUrlSignUp),
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );
    print(jsonDecode(response.body));

    final body = jsonDecode(response.body);

    if (body['error'] != null) {
      throw AuthException(key: body['error']['message']);
    } else {
      _token = body['idToken'];
      _email = body['email'];
      _uid = body['localId'];
      _expireDate =
          DateTime.now().add(Duration(seconds: int.parse(body['expiresIn'])));
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    final response = await http.post(
      Uri.parse(_authUrlSignIn),
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );
    print(jsonDecode(response.body));
    final body = jsonDecode(response.body);

    if (body['error'] != null) {
      throw AuthException(key: body['error']['message']);
    } else {
      _token = body['idToken'];
      _email = body['email'];
      _uid = body['localId'];
      _expireDate =
          DateTime.now().add(Duration(seconds: int.parse(body['expiresIn'])));
      notifyListeners();
    }
  }
}
