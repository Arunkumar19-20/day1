import 'dart:convert';
import 'package:http/http.dart' as http;

class AttendanceAPI {

  /// 🔥 If using Android Emulator → use 10.0.2.2
  /// 🔥 If real device → put your PC WiFi IPv4 example 192.168.1.10
  static const String base = "http://10.220.32.211:8091/api/attendance";

  /// Supervisor base URL (NEW)
  static const String supervisorBase = "http://10.220.32.211:8091/api/supervisor";

  // =====================================================
  // 1️⃣ GET SUMMARY (present/absent/nonCompliance)
  // =====================================================
  static Future<Map<String, dynamic>> getSummary(String period) async {
    final res = await http.get(Uri.parse("$base/summary?period=$period"));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw "Summary API Failed ❌ ${res.statusCode}";
  }

  // =====================================================
  // 2️⃣ SEARCH WORKER
  // =====================================================
  static Future<List<dynamic>> searchWorker(String workerId) async {
    final res = await http.get(Uri.parse("$base/search?q=$workerId"));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw "Search Failed ❌ Code: ${res.statusCode}";
  }

  // =====================================================
  // 3️⃣ GET WORKER FULL HISTORY (PDF use)
  // =====================================================
  static Future<List<dynamic>> getWorker(String workerId) async {
    final res = await http.get(Uri.parse("$base/worker/$workerId"));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw "Worker History Load Failed ❌";
  }

  // =====================================================
  // 4️⃣ GET ATTENDANCE FILTER BY STATUS
  // =====================================================
  static Future<List<dynamic>> getByStatus(String status) async {
    final res = await http.get(Uri.parse("$base/status/$status"));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw "Status Filter Failed ❌";
  }

  // =====================================================
  // 5️⃣ GET ATTENDANCE BY PERIOD
  // =====================================================
  static Future<List<dynamic>> getByPeriod(String period) async {
    final res = await http.get(Uri.parse("$base/period/$period"));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw "Period Load Failed ❌";
  }

  // =====================================================
  // 6️⃣ RESOLVE NON-COMPLIANCE
  // =====================================================
  static Future<bool> resolveIssue(String workerId) async {
    final res = await http.put(Uri.parse("$base/resolve/$workerId"));
    return res.statusCode == 200;
  }

  // =====================================================
  // ⭐ NEW — GET SUPERVISOR DETAILS
  // /api/supervisor/{supervisorId}
  // =====================================================
  static Future<Map<String, dynamic>> getSupervisor(String supervisorId) async {
    final url = "$supervisorBase/$supervisorId";
    print("➡ Supervisor API: $url");

    final res = await http.get(Uri.parse(url));
    print("RAW RESPONSE: ${res.body}");

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      return json['data'];
    }

    throw "Failed ${res.statusCode}";
  }



}
