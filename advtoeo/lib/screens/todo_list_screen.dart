import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'task_screen.dart';

class TodoListScreen extends StatefulWidget {
  final int userId;
  final String username;

  const TodoListScreen({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late Future<List<dynamic>> listsFuture;

  @override
  void initState() {
    super.initState();
    listsFuture = ApiService.getListsByUser(widget.userId);
  }

  void refresh() {
    setState(() {
      listsFuture = ApiService.getListsByUser(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.username}'s Todo Lists")),
      body: FutureBuilder(
        future: listsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final lists = snapshot.data ?? [];

          if (lists.isEmpty) {
            return const Center(child: Text("No lists found"));
          }

          return ListView.builder(
            itemCount: lists.length,
            itemBuilder: (context, i) {
              final list = lists[i];
              return ListTile(
                title: Text(list.title),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskScreen(listId: list.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          TextEditingController controller = TextEditingController();

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("New List"),
              content: TextField(controller: controller),
              actions: [
                TextButton(
                  onPressed: () async {
                    await ApiService.createList(
                      controller.text,
                      widget.userId,
                    );
                    Navigator.pop(context);
                    refresh();
                  },
                  child: const Text("Save"),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
