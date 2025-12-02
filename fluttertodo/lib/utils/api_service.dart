import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = 'http://172.20.43.227:8090/api/todos';

  static Future<List<dynamic>> getTasks() async {
    final res = await http.get(Uri.parse('$baseUrl/all'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load tasks');
  }

  static Future<void> addTask(String title, String time) async {
    await http.post(Uri.parse('$baseUrl/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title, 'time': time, 'completed': false}));
  }

  static Future<void> toggleTask(Map task) async {
    await http.put(Uri.parse('$baseUrl/update/${task['id']}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({...task, 'completed': !task['completed']}));
  }

  static Future<void> deleteTask(int id) async {
    await http.delete(Uri.parse('$baseUrl/delete/$id'));
  }
}
