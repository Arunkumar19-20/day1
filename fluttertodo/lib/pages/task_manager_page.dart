import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/api_service.dart';

class TaskManagerPage extends StatefulWidget {
  const TaskManagerPage({super.key});

  @override
  State<TaskManagerPage> createState() => _TaskManagerPageState();
}

class _TaskManagerPageState extends State<TaskManagerPage> {
  final textCtrl = TextEditingController();
  final timeCtrl = TextEditingController();
  List tasks = [];
  final player = AudioPlayer();
  final Set<int> scheduled = {};

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
      tasks = await ApiService.getTasks();
      setState(() {});
      scheduleReminders();
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void addTask() async {
    if (textCtrl.text.isEmpty) return;
    await ApiService.addTask(textCtrl.text, timeCtrl.text);
    textCtrl.clear();
    timeCtrl.clear();
    loadTasks();
  }

  void toggleTask(task) async {
    await ApiService.toggleTask(task);
    loadTasks();
  }

  void deleteTask(int id) async {
    await ApiService.deleteTask(id);
    loadTasks();
  }

  void scheduleReminders() {
    for (var task in tasks) {
      if (task['time'] != null && !task['completed'] && !scheduled.contains(task['id'])) {
        final diff = DateTime.parse(task['time']).millisecondsSinceEpoch - DateTime.now().millisecondsSinceEpoch;
        if (diff > 0) {
          Future.delayed(Duration(milliseconds: diff), () async {
            await player.play(AssetSource("preview.mp3"));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("⏰ Reminder: ${task['title']}")));
            }
            scheduled.remove(task['id']);
          });
          scheduled.add(task['id']);
        }
      }
    }
  }

  void downloadTasks() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/tasks.txt");
    await file.writeAsString(jsonEncode(tasks));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("📥 Tasks saved to ${file.path}")));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade800,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(controller: textCtrl, decoration: const InputDecoration(hintText: "Enter task", filled: true, fillColor: Colors.white)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: timeCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(hintText: "Pick time", filled: true, fillColor: Colors.white),
                  onTap: () async {
                    final dt = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (dt == null) return;
                    final tm = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (tm != null) {
                      final full = DateTime(dt.year, dt.month, dt.day, tm.hour, tm.minute);
                      timeCtrl.text = full.toIso8601String();
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: addTask, child: const Text("Add")),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (_, i) {
                final t = tasks[i];
                return Card(
                  color: Colors.grey.shade700,
                  child: ListTile(
                    title: Text(
                      t['title'],
                      style: TextStyle(
                        color: Colors.white,
                        decoration: t['completed'] ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: t['time'] != null
                        ? Text(DateTime.parse(t['time']).toLocal().toString(), style: const TextStyle(color: Colors.white70))
                        : null,
                    trailing: Wrap(
                      spacing: 10,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.done, color: Colors.greenAccent),
                          onPressed: () => toggleTask(t),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => deleteTask(t['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(onPressed: downloadTasks, child: const Text("Download Tasks")),
        ],
      ),
    );
  }
}
