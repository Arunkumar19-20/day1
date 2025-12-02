import 'task.dart';

class TodoListModel {
  final int id;
  final String title;
  final List<TaskModel> tasks;

  TodoListModel({
    required this.id,
    required this.title,
    required this.tasks,
  });

  factory TodoListModel.fromJson(Map<String, dynamic> json) {
    return TodoListModel(
      id: json['id'],
      title: json['title'],
      tasks: (json['tasks'] as List? ?? [])
          .map((e) => TaskModel.fromJson(e))
          .toList(),
    );
  }
}
