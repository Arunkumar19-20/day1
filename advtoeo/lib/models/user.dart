import 'package:flutter_todo_app/models/todo_list.dart';

class UserModel {
  final int id;
  final String username;
  final String email;
  final List<TodoListModel> todoLists;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.todoLists,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      todoLists: (json['todoLists'] as List? ?? [])
          .map((e) => TodoListModel.fromJson(e))
          .toList(),
    );
  }
}
