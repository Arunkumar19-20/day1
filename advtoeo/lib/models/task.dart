class TaskModel {
  final int id;
  final String description;
  final bool completed;

  TaskModel({
    required this.id,
    required this.description,
    required this.completed,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      description: json['description'],
      completed: json['completed'],
    );
  }
}
