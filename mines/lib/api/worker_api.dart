import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class WorkerApi {

  /// YOUR BACKEND IP (Change only this)
  final String base = "http://10.220.32.211:8091/api/worker";

  //-------------------------------------------
  /// 1) CREATE WORKER (JSON Only)
  //-------------------------------------------
  Future<bool> createWorker(Map<String, dynamic> workerData) async {
    try {
      final response = await http.post(
        Uri.parse("$base/create"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(workerData),
      );

      print("🟢 Worker Create Response → ${response.body}");

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result["success"] == true;
      }
      return false;

    } catch (e) {
      print("❌ Create Worker Error → $e");
      return false;
    }
  }

  //-------------------------------------------
  /// 2) UPLOAD WORKER IMAGE (Multipart)
  //-------------------------------------------
  Future<bool> uploadWorkerImage(String workerId, File imageFile) async {
    try {
      var request = http.MultipartRequest(
          "POST", Uri.parse("$base/upload-image/$workerId"));

      request.files.add(await http.MultipartFile.fromPath("image", imageFile.path));

      var response = await request.send();
      print("🟡 Upload Status → ${response.statusCode}");

      return response.statusCode == 200;

    } catch (e) {
      print("❌ Upload Image Error → $e");
      return false;
    }
  }

  //-------------------------------------------
  /// 3) GET WORKER IMAGE URL (for Image.network)
  //-------------------------------------------
  String getWorkerImageUrl(String workerId) {
    return "$base/image/$workerId";  // <--- use in Image.network()
  }
}
