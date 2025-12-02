import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TaskScreen extends StatefulWidget {
  final int listId;

  const TaskScreen({super.key, required this.listId});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late Future tasksFuture;

  @override
  void initState() {
    super.initState();
    tasksFuture = ApiService.getTasksByList(widget.listId);
  }

  void refresh() {
    setState(() {
      tasksFuture = ApiService.getTasksByList(widget.listId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tasks")),
      body: FutureBuilder(
        future: tasksFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data!;

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, i) {
              final task = tasks[i];
              return CheckboxListTile(
                value: task.completed,
                title: Text(task.description),
                onChanged: (value) {},
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TextEditingController controller = TextEditingController();

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("New Task"),
              content: TextField(controller: controller),
              actions: [
                TextButton(
                  onPressed: () async {
                    await ApiService.createTask(
                      controller.text,
                      widget.listId,
                    );
                    Navigator.pop(context);
                    refresh();
                  },
                  child: const Text("Save"),
                )
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
