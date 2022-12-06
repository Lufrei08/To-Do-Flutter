import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    tasks = catchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.grey[850],
        title: const Text('To Do'),
        leading: IconButton(
          icon: const Icon(Icons.logout),
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
        ),
        toolbarTextStyle:
            const TextTheme(headline6: TextStyle(color: Colors.white))
                .bodyText2,
        titleTextStyle: const TextTheme(
            headline6: TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        )).headline6,
      ),
      body: FutureBuilder<List>(
        future: tasks,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.separated(
                itemBuilder: (context, index) {
                  return ListTile(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    title: Text(snapshot.data![index]['conteudo']),
                    trailing: Icon(Icons.check_box_outline_blank),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                itemCount: snapshot.data!.length);
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
    );
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

// Function to missing token
// Future<bool> logout() async {
//   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//   await sharedPreferences.clear();
//   return true;
// }

Future<List> catchTasks() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  var token = sharedPreferences.getString('token');
  var api = apiURL.URl;

  var url = Uri.parse('${api}index/');
  var response = await http.get(url, headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': '$token',
  });

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  return throw Exception('Erro ao carregar dados de usuario!');
}
