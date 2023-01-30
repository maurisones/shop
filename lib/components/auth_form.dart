import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:shop/exceptions/auth_exception.dart';
import 'package:shop/utils/app_routes.dart';

import 'auth.dart';

enum AuthMode { Signup, Login }

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  AuthMode _authMode = AuthMode.Login;

  final _passwordController = TextEditingController();

  bool _isSingUp() => _authMode == AuthMode.Signup;
  bool _isLogin() => _authMode == AuthMode.Login;

  void _switchAuthMode() {
    setState(() {
      if (_isLogin()) {
        _authMode = AuthMode.Signup;
      } else {
        _authMode = AuthMode.Login;
      }
    });
  }

  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ocorreu um erro!'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final isValidForm = _formKey.currentState?.validate() ?? false;

    if (!isValidForm) {
      return null;
    }

    setState(() => _isLoading = true);
    _formKey.currentState?.save();

    Auth auth = Provider.of(context, listen: false);

    try {
      if (_isLogin()) {
        await auth.signIn(_authData['email']!, _authData['password']!);
      } else {
        await auth.signUp(_authData['email']!, _authData['password']!);
      }
      Navigator.of(context).pushNamed(AppRoutes.AUTH_OR_HOME);
    } on AuthException catch (error) {
      _showErrorDialog(error.toString());
    } catch (error) {
      _showErrorDialog('Ocorreu um erro inesperado.');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        height: _isLogin() ? 310 : 400,
        width: deviceSize.width * 0.75,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (email) => _authData['email'] = email ?? '',
                validator: (_email) {
                  final email = _email ?? '';
                  if (email.trim().isEmpty || !email.contains('@')) {
                    return 'E-mail inválido!';
                  } else {
                    return null;
                  }
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Senha'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (password) => _authData['password'] = password ?? '',
                obscureText: true,
                controller: _passwordController,
                validator: (_password) {
                  final password = _password ?? '';
                  if (password.isEmpty || password.length < 5) {
                    return 'Senha inválida!';
                  } else {
                    return null;
                  }
                },
              ),
              if (_isSingUp())
                TextFormField(
                  decoration: InputDecoration(labelText: 'Confirmar Senha'),
                  keyboardType: TextInputType.emailAddress,
                  obscureText: true,
                  validator: _isLogin()
                      ? null
                      : (_password) {
                          final password = _password ?? '';
                          if (password != _passwordController.text) {
                            return 'Senhas não conferem!';
                          } else {
                            return null;
                          }
                        },
                ),
              SizedBox(height: 20),
              if (_isLoading)
                CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(
                      _authMode == AuthMode.Login ? 'Entrar' : 'Registrar'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                  ),
                ),
              Spacer(),
              TextButton(
                onPressed: _switchAuthMode,
                child: Text(
                  _isLogin() ? 'Registrar-me.' : 'Já tenho conta.',
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
