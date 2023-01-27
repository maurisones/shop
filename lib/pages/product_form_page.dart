import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/app_drawer.dart';
import 'package:shop/models/product.dart';
import 'package:shop/models/product_list.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _imageUrlController = TextEditingController();
  final _imageUrlFocus = FocusNode();

  // globalkey associado ao formulário
  final _formKey = GlobalKey<FormState>();

  // mapa usado para manter os dados dos campos do formulario
  final _formData = Map<String, Object>();

  bool _isLoading = false;

  // metodo associado com a submissão do formulário no botão save do appbar e no
  // onFieldSubmitted do campo imageUrl, quando o form for submetido, o método
  // _formKey.currentState?.save() irá acionar o onSaved de cada campo do formulario
  // que irá transferir o valor do campo para o mapa para depois criar um objeto
  // Product para salvar.
  void _submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    //print('submit');
    _formKey.currentState?.save();
    print(_formData.toString());

    setState(() => _isLoading = true);

    // definido o id (novo ou edição)
    bool hasId = _formData.containsKey('id');

    Product product = Product(
      id: hasId
          ? _formData['id']!.toString()
          : Random().nextDouble().toString(),
      name: _formData['name'] as String,
      description: _formData['description'] as String,
      price: _formData['price'] as double,
      imageUrl: _formData['imageUrl'] as String,
    );

    try {
      await Provider.of<ProductList>(context, listen: false)
          .addProduct(product);
    } catch (error) {
      // show dialog retorna um Future então preciso do await para esperar
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ocorreu um erro!'),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            )
          ],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
      Navigator.of(context).pop();
    }
  }

  // para pegar o produto a ser editado, depende de setar o initialvalue de cada campo se
  // não utilizar controller
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_formData.isEmpty) {
      final arg = ModalRoute.of(context)?.settings.arguments;

      if (arg != null) {
        final product = arg as Product;
        _formData['id'] = product.id;
        _formData['name'] = product.name;
        _formData['price'] = product.price;
        _formData['description'] = product.description;
        _formData['imageUrl'] = product.imageUrl;

        _imageUrlController.text = product.imageUrl;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _imageUrlFocus.addListener(updateImage);
  }

  void updateImage() {
    setState(() {});
    print("updateImage ...");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulário de produto'),
        actions: [IconButton(onPressed: _submitForm, icon: Icon(Icons.save))],
      ),
      //drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _formData['name']?.toString(),
                      decoration: InputDecoration(labelText: 'Nome'),
                      textInputAction: TextInputAction.next,
                      onSaved: (name) {
                        _formData['name'] = name ?? 'Não informado';
                      },
                      validator: (_name) {
                        final name = _name ?? '';

                        if (name.trim().isEmpty) {
                          return 'Nome é obrigatório';
                        }
                        if (name.trim().length < 3) {
                          return 'Nome deve ter no mínimo 3 letras';
                        }

                        // null aqui significa validação ok
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _formData['price']?.toString(),
                      decoration: InputDecoration(labelText: 'Preço'),
                      textInputAction: TextInputAction.next,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      onSaved: (price) {
                        _formData['price'] = double.parse(price ?? '0');
                      },
                    ),
                    TextFormField(
                      initialValue: _formData['description']?.toString(),
                      decoration: InputDecoration(labelText: 'Descrição'),
                      //textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      onSaved: (description) {
                        _formData['description'] =
                            description ?? 'Não informado';
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextFormField(
                            //initialValue: formData['imageUrl']?.toString(),
                            decoration:
                                InputDecoration(labelText: 'Url da Imagem'),
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.url,
                            controller: _imageUrlController,
                            onFieldSubmitted: (value) => _submitForm(),
                            onSaved: (imageUrl) {
                              _formData['imageUrl'] =
                                  imageUrl ?? 'Não informado';
                            },
                            validator: (_url) {
                              final String url = _url ?? '';
                              final bool uriValid =
                                  Uri.tryParse(url)?.hasAbsolutePath ?? false;
                              final bool endsWithFile =
                                  url.toLowerCase().endsWith('.png') ||
                                      url.toLowerCase().endsWith('.jpg') ||
                                      url.toLowerCase().endsWith('.jpg') ||
                                      url.toLowerCase().endsWith('.jpeg') ||
                                      url.toLowerCase().endsWith('.gif');
                              if (!uriValid) {
                                return 'Url inválida!';
                              }

                              if (!endsWithFile) {
                                return 'Extensão do arquivo inválida!';
                              }

                              return null;
                            },
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(
                            top: 10,
                            left: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: _imageUrlController.text.isEmpty
                              ? Text('Preview')
                              : Image.network(_imageUrlController.text),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
