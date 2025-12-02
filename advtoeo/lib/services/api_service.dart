import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:8087";

  // ---------------- USERS -----------------
  static Future<List<dynamic>> getUsers() async {
    final response = await http.get(Uri.parse("$baseUrl/users"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception("Failed to fetch users: ${response.statusCode}");
    }
  }

  static Future<void> createUser(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/users"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to create user");
    }
  }

  // ------------- TODO LISTS ----------------
  static Future<List<dynamic>> getListsByUser(int userId) async {
    final response = await http.get(Uri.parse("$baseUrl/lists/user/$userId"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception("Failed to fetch lists");
    }
  }

  static Future<void> createList(String title, int userId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/lists"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": title,
        "userId": userId,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to create list");
    }
  }

  // ------------- TASKS ----------------
  static Future<List<dynamic>> getTasksByList(int listId) async {
    final response =
    await http.get(Uri.parse("$baseUrl/tasks/list/$listId"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception("Failed to fetch tasks");
    }
  }

  static Future<void> createTask(String description, int listId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/tasks"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "description": description,
        "completed": false,
        "listId": listId,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to create task");
    }
  }
}
