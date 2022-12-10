import 'dart:convert';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:to_do/login_page.dart';
import 'URL/API.dart' as apiURL;

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formkey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
            key: _formkey,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Username'),
                        controller: _usernameController,
                        keyboardType: TextInputType.text,
                        validator: (username) {
                          if (username == null || username.isEmpty) {
                            return 'Por favor, digite um username';
                          }
                          return null;
                        }),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Senha'),
                      controller: _passwordController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      validator: (senha) {
                        if (senha == null || senha.isEmpty) {
                          return 'Por favor, digite uma senha';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Email'),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (email) {
                        if (email == null || email.isEmpty) {
                          return 'Por favor, digite um email';
                        } else if (!RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(_emailController.text)) {
                          return 'Por favor, digite um email válido!';
                        }
                        return null;
                      },
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (_formkey.currentState!.validate()) {
                          bool match = await register();
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          if (match) {
                            // ignore: use_build_context_synchronously
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()));
                          } else {
                            _passwordController.clear();
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        }
                      },
                      child: const Text('Registrar'),
                    ),
                  ],
                ),
              ),
            )));
  }

  // ignore: prefer_const_constructors
  final snackBar = SnackBar(
    content: const Text(
      'Username, senha ou email inválidos!',
      textAlign: TextAlign.center,
    ),
    backgroundColor: Colors.redAccent,
  );

  Future<bool> register() async {
    var api = apiURL.URl;

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var url = Uri.parse('${api}signup');
    var response = await http.post(
      url,
      body: {
        'username': _usernameController.text,
        'password': _passwordController.text,
        'email': _emailController.text
      },
    );
    if (response.statusCode == 201) {
      await sharedPreferences.setString(
          'token', "${jsonDecode(response.body)['token']}");
      print(jsonDecode(response.body)['token']);
      return true;
    } else {
      print(jsonDecode(response.body));
      return false;
    }
  }
}
