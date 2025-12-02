import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

Future<bool> uploadWorkerImage(String workerId, String baseUrl) async {
  final picker = ImagePicker();
  final image = await picker.pickImage(source: ImageSource.camera);

  if (image == null) return false;

  try {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/api/worker/upload-image/$workerId"),
    );

    request.files.add(await http.MultipartFile.fromPath("image", image.path));

    var response = await request.send();
    return response.statusCode == 200;

  } catch (e) {
    print("UPLOAD ERROR: $e");
    return false;
  }
}
