import 'dart:convert';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:to_do/home_page.dart';
import 'package:to_do/register_page.dart';
import 'package:to_do/welcome_page.dart';
import 'URL/API.dart' as apiURL;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formkey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final bool _passwordReveal = false;

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
                            return 'Por favor, digite seu username';
                          }
                          return null;
                        }),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                      ),
                      keyboardType: TextInputType.text,
                      validator: (senha) {
                        if (senha == null || senha.isEmpty) {
                          return 'Por favor, digite sua senha';
                        }
                        return null;
                      },
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (_formkey.currentState!.validate()) {
                          bool match = await login();
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          if (match) {
                            // ignore: use_build_context_synchronously
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WelcomePage()));
                          } else {
                            _passwordController.clear();
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        }
                      },
                      child: const Text('Login'),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RegisterPage()));
                        },
                        child: const Text('Registro'))
                  ],
                ),
              ),
            )));
  }

  // ignore: prefer_const_constructors
  final snackBar = SnackBar(
    content: const Text(
      'Username ou senha inv??lidos!',
      textAlign: TextAlign.center,
    ),
    backgroundColor: Colors.redAccent,
    behavior: SnackBarBehavior.floating,
  );

  Future<bool> login() async {
    var api = apiURL.URl;

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var url = Uri.parse('${api}login');
    var response = await http.post(
      url,
      body: {
        'username': _usernameController.text,
        'password': _passwordController.text
      },
    );
    if (response.statusCode == 200) {
      String token = jsonDecode(response.body)['token'];
      String idUser = jsonDecode(response.body)['_id'];
      await sharedPreferences.setString('token', 'Bearer $token');
      await sharedPreferences.setString('idUser', idUser);
      return true;
    } else {
      print(jsonDecode(response.body));
      return false;
    }
  }
}
