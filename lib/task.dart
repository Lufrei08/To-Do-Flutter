import 'dart:convert';

Task taskFromJson(String str) => Task.fromJson(json.decode(str));

String taskToJson(Task data) => json.encode(data.toJson());

class Task {
  Task(
      {required this.id,
      required this.conteudo,
      required this.status,
      required this.idUser});

  String id;
  String conteudo;
  bool status;
  String idUser;

  factory Task.fromJson(Map<String, dynamic> json) => Task(
      id: json['_id'],
      conteudo: json['conteudo'],
      status: json['status'],
      idUser: json['idUser']);

  Map<String, dynamic> toJson() =>
      {"_id": id, "conteudo": conteudo, "status": status, "idUser": idUser};
}
