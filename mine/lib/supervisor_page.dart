import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'model/worker_model.dart';

class SupervisorPage extends StatefulWidget {
  const SupervisorPage({super.key});

  @override
  State<SupervisorPage> createState() => _SupervisorPageState();
}

class _SupervisorPageState extends State<SupervisorPage> {
  final String baseUrl = "http://localhost:8080/api/workers";
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  List<Worker> workers = [];

  @override
  void initState() {
    super.initState();
    fetchWorkers();
  }

  Future<void> fetchWorkers() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      setState(() {
        workers = data.map((e) => Worker.fromJson(e)).toList();
      });
    }
  }

  Future<void> addWorker() async {
    final name = _nameController.text.trim();
    final position = _positionController.text.trim();
    if (name.isEmpty || position.isEmpty) return;

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'position': position}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      _nameController.clear();
      _positionController.clear();
      fetchWorkers();
    }
  }

  Future<void> downloadFile(String url, String fileName) async {
    if (await Permission.storage.request().isGranted) {
      final response = await http.get(Uri.parse(url));
      final Directory dir = await getApplicationDocumentsDirectory();
      final File file = File('${dir.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloaded $fileName')));
    }
  }

  Future<void> downloadConsolidated() async {
    final url = "$baseUrl/consolidated";
    await downloadFile(url, "consolidated_workers.csv");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Supervisor Dashboard"),
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: downloadConsolidated),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Worker Name")),
                TextField(controller: _positionController, decoration: const InputDecoration(labelText: "Position")),
                ElevatedButton(onPressed: addWorker, child: const Text("Add Worker")),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: workers.length,
              itemBuilder: (context, index) {
                final worker = workers[index];
                return ListTile(
                  title: Text(worker.name),
                  subtitle: Text(worker.position),
                  trailing: worker.reportPath.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () => downloadFile("$baseUrl/${worker.id}/report", "${worker.name}.pdf"),
                  )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
