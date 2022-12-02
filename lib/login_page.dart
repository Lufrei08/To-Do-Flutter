import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formkey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
            key: _formkey,
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16),
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
                      decoration: const InputDecoration(labelText: 'Senha'),
                      controller: _passwordController,
                      keyboardType: TextInputType.text,
                      validator: (senha) {
                        if (senha == null || senha.isEmpty) {
                          return 'Por favor, digite sua senha';
                        }
                        return null;
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        login();
                      },
                      child: Text('Login'),
                    ),
                  ],
                ),
              ),
            )));
  }

  Future<bool> login() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.1.4.215:3000/login');
    var response = await http.post(
      url,
      body: {
        'username': _usernameController.text,
        'password': _passwordController.text
      },
    );
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      return true;
    } else {
      print(jsonDecode(response.body));
      return false;
    }
  }
}
