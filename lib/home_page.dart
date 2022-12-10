// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:to_do/task.dart';

import 'URL/API.dart' as apiURL;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:to_do/welcome_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List> tasks;

  final _formkey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  // @override
  // void initState() {
  //   super.initState();
  //   tasks = catchTasks();
  // }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    tasks = catchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'To Do',
          textAlign: TextAlign.center,
        ),
        elevation: 1,
        backgroundColor: Color.fromARGB(255, 211, 115, 227),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              bool exit = await logout();
              if (exit) {
                // ignore: use_build_context_synchronously
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WelcomePage(),
                    ));
              }
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: FutureBuilder<List>(
        future: catchTasks(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.separated(
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data![index];

                  return Dismissible(
                    key: Key(item.id[index]),
                    onDismissed: (DismissDirection dir) async {
                      //print(item.id);
                      print(dir);
                      if (dir == DismissDirection.startToEnd) {
                        print('Vo edita');

                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Editar tarefa'),
                                content: TextFormField(
                                  key: _formkey,
                                  controller: _textController,
                                  validator: (tarefa) {
                                    if (tarefa == null || tarefa.isEmpty) {
                                      return 'Algo está errado';
                                    }
                                    return null;
                                  },
                                ),
                                actions: [
                                  FlatButton(
                                      onPressed: () async {
                                        bool save = await editTask(
                                            item.id, _textController.text);
                                        _textController.clear();
                                        if (save) {
                                          // ignore: use_build_context_synchronously
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      HomePage()));
                                        }
                                      },
                                      child: const Text('Salvar'))
                                ],
                              );
                            });
                      } else if (dir == DismissDirection.endToStart) {
                        print('Vo apagá');
                        // bool deleted =
                        await deleteTask(item.id);
                      }
                    },
                    background: Container(
                      color: Colors.orange,
                      alignment: Alignment.centerLeft,
                      child: const Icon(Icons.update),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      child: const Icon(Icons.delete),
                    ),
                    child: ListTile(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                      title: Text(item.conteudo),
                      trailing: Checkbox(
                          value: item.status,
                          onChanged: (value) async {
                            String valor = value.toString();
                            print(valor);
                            bool edited = await editStatus(item.id, valor);
                            if (edited) {
                              setState(() {
                                tasks = catchTasks();
                              });
                            }
                            return;
                          }),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                });
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Erro ao carregar dados do usuário!'),
            );
          }

          // ignore: prefer_const_constructors
          return Center(
            child: const CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Adicionar tarefa'),
                    content: TextFormField(
                      key: _formkey,
                      controller: _textController,
                      validator: (tarefa) {
                        if (tarefa == null || tarefa.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                        return null;
                      },
                    ),
                    actions: [
                      FlatButton(
                          onPressed: () async {
                            bool save = await addTask();
                            if (save) {
                              setState(() {
                                tasks = catchTasks();
                              });
                            }
                            return;
                          },
                          child: const Text('Salvar'))
                    ],
                  );
                });
          },
          child: const Icon(Icons.add)),
    );
  }

  final snackBar = const SnackBar(
    content: Text(
      'Preencha algo antes de salvar!',
      textAlign: TextAlign.center,
    ),
    backgroundColor: Colors.redAccent,
  );

  Future<List<Task>> catchTasks() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    var api = apiURL.URl;

    var url = Uri.parse('${api}index/');
    var response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': '$token',
    });
    List<Task> tasks = List<Task>.empty(growable: true);

    if (response.statusCode == 200) {
      List resList = jsonDecode(response.body);
      resList.forEach((mTask) {
        tasks.add(Task.fromJson(mTask));
      });
    }
    return tasks;
  }

  // Future<List> catchTasks() async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   var token = sharedPreferences.getString('token');
  //   var api = apiURL.URl;

  //   var url = Uri.parse('${api}index/');
  //   var response = await http.get(url, headers: {
  //     'Content-Type': 'application/json',
  //     'Accept': 'application/json',
  //     'Authorization': '$token',
  //   });

  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   }
  //   return throw Exception('Erro ao carregar dados de usuario!');
  // }

  Future<bool> addTask() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    var api = apiURL.URl;

    var url = Uri.parse('${api}index');
    var response = await http.post(
      url,
      headers: {
        'Authorization': '$token',
      },
      body: {
        'conteudo': _textController.text,
      },
    );

    if (response.statusCode == 201) {
      print(jsonDecode(response.body));

      return true;
    } else {
      print(jsonDecode(response.body));
      return false;
    }
  }

  Future<bool> editStatus(String id, String valor) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    var api = apiURL.URl;

    var url = Uri.parse('${api}index/${id}');
    var response = await http.put(
      url,
      headers: {
        'Authorization': '$token',
      },
      body: {
        'status': valor,
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

  Future<bool> editTask(String id, String conteudo) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    var api = apiURL.URl;

    var url = Uri.parse('${api}index/${id}');
    var response = await http.put(
      url,
      headers: {
        'Authorization': '$token',
      },
      body: {
        'conteudo': conteudo,
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

  Future<bool> logout() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');

    var api = apiURL.URl;

    var url = Uri.parse('${api}logout');
    var response = await http.post(url, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': '$token',
    });
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      await sharedPreferences.clear();
      return true;
    } else {
      print(jsonDecode(response.body));
      return false;
    }
  }

  Future<bool> deleteTask(String id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    var api = apiURL.URl;

    var url = Uri.parse('${api}index/${id}');
    var response = await http.delete(
      url,
      headers: {
        'Authorization': '$token',
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

// Function to missing token
// Future<bool> logout() async {
//   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//   await sharedPreferences.clear();
//   return true;
// }
