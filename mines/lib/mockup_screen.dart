// lib/screens/mockup_screen.dart
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'attendance_api.dart';
import 'models/supervisor.dart';

class MockupScreen extends StatefulWidget {
  final String supervisorId;

  const MockupScreen({super.key, required this.supervisorId});

  @override
  State<MockupScreen> createState() => _MockupScreenState();
}

class _MockupScreenState extends State<MockupScreen> {
  bool expanded = false;

  static const background = Color(0xFFC6E4E9);
  static const cardColor = Color(0xFF769BA0);
  static const yellow = Color(0xFFF7C869);

  TextEditingController searchController = TextEditingController();

  /// period = daily / weekly / monthly
  String period = "daily";

  /// Data from backend summary
  List<Map<String, dynamic>> present = [];
  List<Map<String, dynamic>> absent = [];
  List<Map<String, dynamic>> nonCompliance = [];

  /// Search results (list of attendance records)
  List<Map<String, dynamic>> filteredWorkers = [];

  bool loadingSummary = false;
  bool loadingSearch = false;

  // --- Supervisor Controllers (NEW) ---
  final supervisorId = TextEditingController();
  final name = TextEditingController();
  final phone = TextEditingController();
  final dob = TextEditingController();
  final bloodGroup = TextEditingController();
  final shift = TextEditingController();
  final address = TextEditingController();
  final workingArea = TextEditingController();

  Map<String, dynamic>? supervisor;

  @override
  void initState() {
    super.initState();
    _loadSummary();
    _loadSupervisor(); // NEW: load supervisor details
  }

  @override
  void dispose() {
    // dispose controllers
    searchController.dispose();
    supervisorId.dispose();
    name.dispose();
    phone.dispose();
    dob.dispose();
    bloodGroup.dispose();
    shift.dispose();
    workingArea.dispose();
    address.dispose();
    super.dispose();
  }

  Future<void> _loadSummary() async {
    setState(() => loadingSummary = true);
    try {
      final data = await AttendanceAPI.getSummary(period);
      setState(() {
        present = List<Map<String, dynamic>>.from(data['present'] ?? []);
        absent = List<Map<String, dynamic>>.from(data['absent'] ?? []);
        nonCompliance =
        List<Map<String, dynamic>>.from(data['nonCompliance'] ?? []);
      });
    } catch (e) {
      debugPrint("Error loading summary: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load summary: $e")),
      );
    } finally {
      if (mounted) setState(() => loadingSummary = false);
    }
  }

  /// NEW: load supervisor data from backend and fill controllers
  Future<void> _loadSupervisor() async {
    try {
      final data = await AttendanceAPI.getSupervisor(widget.supervisorId);

      print("SUPERVISOR DATA: $data");

      if (!mounted) return;

      setState(() {
        supervisor = data; // store object for display

        supervisorId.text = data['supervisorId'] ?? '';
        name.text = data['name'] ?? '';
        dob.text = data['dob'] ?? '';
        phone.text = data['phone'] ?? '';
        bloodGroup.text = data['bloodGroup'] ?? '';
        shift.text = data['shift'] ?? '';
        address.text = data['address'] ?? '';
        workingArea.text = data['workingArea'] ?? '';
      });
    } catch (e) {
      print("Supervisor load error: $e");
    }
  }



  int _countFor(String type) {
    switch (type) {
      case "present":
        return present.length;
      case "absent":
        return absent.length;
      case "noncompliance":
        return nonCompliance.length;
      default:
        return 0;
    }
  }

  int get _nonComplianceCount => nonCompliance.length;

  // ---------------------------------------------------------------------------
  // NON-COMPLIANCE NOTIFICATION DIALOG (from backend list)
  // ---------------------------------------------------------------------------
  void _showNonComplianceNotifications() {
    final list = nonCompliance; // already from backend

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SafeArea(
            minimum: const EdgeInsets.all(8),
            child: Container(
              padding: const EdgeInsets.all(14),
              constraints: const BoxConstraints(maxHeight: 560, maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Non-Compliance Notifications (${list.length})",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  const Divider(height: 18),
                  Expanded(
                    child: list.isEmpty
                        ? const Center(
                      child: Text("No non-compliance records"),
                    )
                        : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 14),
                      separatorBuilder: (_, __) => const Divider(height: 14),
                      itemCount: list.length,
                      itemBuilder: (_, idx) {
                        final item = list[idx];
                        final workerId = item['workerId'] ?? '-';
                        final ppe = item['ppeIssue'] ?? '-';
                        final time = item['timestamp'] ?? '-';
                        final location = item['locationName'] ?? '-';

                        // Name is not in entity; if you add workerName later in backend,
                        // this will automatically display.
                        final name = item['workerName'] ?? "Worker $workerId";

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "$name  •  $workerId",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text("Missing PPE: $ppe"),
                                  Text("Time: $time"),
                                  Text("Location: $location"),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: 88,
                                maxWidth: 100,
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade400,
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  try {
                                    await AttendanceAPI.resolveIssue(workerId);
                                    setState(() {
                                      nonCompliance.removeAt(idx);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text("Non-compliance resolved")));
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Failed to resolve: $e")));
                                  }
                                },
                                child: const Text(
                                  "Resolve",
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Close"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Reuse for showing lists
  void _showListOverlay(BuildContext context, String type) {
    List<Map<String, dynamic>> data;
    if (type == "present") {
      data = present;
    } else if (type == "absent") {
      data = absent;
    } else {
      data = nonCompliance;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          insetPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxHeight: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _titleFor(type),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "(${data.length})",
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close),
                    )
                  ],
                ),
                const Divider(),
                const SizedBox(height: 6),
                Expanded(
                  child: data.isEmpty
                      ? const Center(child: Text("No records"))
                      : ListView.separated(
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final item = data[i];
                      final workerId = item["workerId"] ?? "";
                      final name = item["workerName"] ?? "Worker $workerId";
                      final location = item["locationName"] ?? "-";
                      final timestamp = item["timestamp"] ?? "-";
                      final ppe = item["ppeIssue"];

                      Widget subtitle;
                      if (type == "present") {
                        subtitle = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Status: Present"),
                            Text("Location: $location"),
                            Text("Time: $timestamp"),
                          ],
                        );
                      } else if (type == "absent") {
                        subtitle = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Status: Absent"),
                            Text("Time: $timestamp"),
                          ],
                        );
                      } else {
                        subtitle = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Missing PPE: ${ppe ?? '-'}"),
                            Text("Location: $location"),
                            Text("Time: $timestamp"),
                          ],
                        );
                      }

                      return ListTile(
                        leading: _iconFor(type),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: subtitle,
                        trailing: Text(
                          workerId,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yellow,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text("Close"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _titleFor(String type) {
    if (type == "present") return "Present";
    if (type == "absent") return "Absent";
    return "Non-Compliance";
  }

  Widget _iconFor(String type) {
    if (type == "present") {
      return const Icon(Icons.circle, color: Colors.green, size: 18);
    }
    if (type == "absent") {
      return const Icon(Icons.remove_circle, color: Colors.red, size: 18);
    }
    return const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20);
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name.text,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                  ),





                  Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none, size: 28),
                            onPressed: _showNonComplianceNotifications,
                          ),
                          if (_nonComplianceCount > 0)
                            Positioned(
                              right: 4,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  _nonComplianceCount.toString(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _supervisorCard(),
              const SizedBox(height: 20),
              _workerLookupCard(),
              const SizedBox(height: 20),
              _summaryCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SUPERVISOR CARD (UPDATED TO SHOW BACKEND DATA)
  // ---------------------------------------------------------------------------
  Widget _supervisorCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => expanded = !expanded),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Supervisor Details",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(
                  expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 28,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _twoLabels("Supervisor ID", "Shift"),
          const SizedBox(height: 8),
          _twoInputs(supervisorId, shift),
          if (expanded) ...[
            const SizedBox(height: 16),
            _twoLabels("DOB", "Phone Number"),
            const SizedBox(height: 8),
            _twoInputs(dob, phone),
            const SizedBox(height: 16),
            _twoLabels("Blood Group", "Working Area"),
            const SizedBox(height: 8),
            _twoInputs(bloodGroup, workingArea),
            const SizedBox(height: 16),
            const Text("Address", style: TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            _inputBox(controller: address, height: 80),
            const SizedBox(height: 26),
          ],
          const SizedBox(height: 8),
          _yellowButton("Create Workers"),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WORKER LOOKUP & INDIVIDUAL REPORT
  // ---------------------------------------------------------------------------
  Widget _workerLookupCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Worker Lookup & Individual Report",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.white70),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) async {
                      setState(() => loadingSearch = true);
                      try {
                        if (value.trim().isEmpty) {
                          filteredWorkers = [];
                        } else {
                          final res = await AttendanceAPI.searchWorker(value.trim());
                          filteredWorkers = List<Map<String, dynamic>>.from(res);
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Search failed: $e")),
                        );
                      } finally {
                        if (mounted) {
                          setState(() => loadingSearch = false);
                        }
                      }
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "search by id",
                      hintStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (loadingSearch) const Center(child: CircularProgressIndicator()),
                if (!loadingSearch && filteredWorkers.isEmpty)
                  const Text(
                    "No workers found",
                    style: TextStyle(fontSize: 15),
                  ),
                // inside _workerLookupCard() > replace only the results widget
                if (!loadingSearch && filteredWorkers.isNotEmpty)
                  ...filteredWorkers.map(
                        (w) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person, color: Colors.black, size: 22),
                            const SizedBox(width: 12),
                            // DETAILS UI
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// 🔥 Shows Name + Worker ID
                                  Text(
                                    "${w['name'] ?? 'Unknown Name'}   •   ${w['workerId']}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  /// 🔥 Shows Shift
                                  Text(
                                    "Shift: ${w['shift'] ?? 'N/A'}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  /// OPTIONAL – show latest attendance info
                                  if (w['status'] != null)
                                    Text("Status: ${w['status']}",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: w['status'] == "present"
                                              ? Colors.green
                                              : w['status'] == "absent"
                                              ? Colors.red
                                              : Colors.orange,
                                        )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (filteredWorkers.isEmpty) return;
                      final worker = filteredWorkers.first;
                      _generateIndividualReport(worker['workerId'] ?? "");
                    },
                    child: Container(
                      width: 180,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: yellow,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: Text(
                          "Generate Report",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SUMMARY CARD
  // ---------------------------------------------------------------------------
  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(35),
      ),
      child: Column(
        children: [
          const Text(
            "Attendance & Compliance Summary",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(30),
            ),
            child: loadingSummary
                ? const Center(child: CircularProgressIndicator())
                : IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showListOverlay(context, "present"),
                      child: _statBlockFixed(
                        "Present",
                        _countFor("present").toString(),
                        Colors.green,
                      ),
                    ),
                  ),
                  _verticalDivider(),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showListOverlay(context, "absent"),
                      child: _statBlockFixed(
                        "Absent",
                        _countFor("absent").toString(),
                        Colors.red,
                      ),
                    ),
                  ),
                  _verticalDivider(),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showListOverlay(context, "noncompliance"),
                      child: _statBlockFixed(
                        "Non-Compliance",
                        _countFor("noncompliance").toString(),
                        Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 35),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _periodPill("daily"),
              _periodPill("weekly"),
              _periodPill("monthly"),
            ],
          ),
          const SizedBox(height: 25),
          GestureDetector(
            onTap: _generateReport,
            child: Container(
              width: 240,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: yellow,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                child: Text(
                  "Generate Report",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateIndividualReport(String workerId) async {
    if (workerId.isEmpty) return;
    try {
      final entries = await AttendanceAPI.getWorker(workerId);

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Individual Worker Report",
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text("Worker ID: $workerId", style: pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 12),
                ...entries.map((e) {
                  final status = e['status'] ?? '-';
                  final period = e['period'] ?? '-';
                  final time = e['timestamp'] ?? '-';
                  final location = e['locationName'] ?? '-';
                  final ppe = e['ppeIssue'];

                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("- Period: $period | Status: $status", style: pw.TextStyle(fontSize: 14)),
                      pw.Text("   Time: $time"),
                      pw.Text("   Location: $location"),
                      if (ppe != null) pw.Text("   Missing PPE: $ppe"),
                      pw.SizedBox(height: 6),
                    ],
                  );
                }).toList(),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to generate report: $e")),
      );
    }
  }

  Future<void> _generateReport() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Attendance & Compliance Report",
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Text("Period: ${period.toUpperCase()}", style: pw.TextStyle(fontSize: 18)),
                pw.SizedBox(height: 12),
                pw.Text(
                  "Present (${present.length})",
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                ...present.map(
                      (w) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("- ${w['workerId']}"),
                      pw.Text("   Status: Present"),
                      pw.Text("   Location: ${w['locationName'] ?? '-'}"),
                      pw.Text("   Time: ${w['timestamp'] ?? '-'}"),
                      pw.SizedBox(height: 6),
                    ],
                  ),
                ),
                pw.SizedBox(height: 14),
                pw.Text(
                  "Absent (${absent.length})",
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                ...absent.map(
                      (w) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("- ${w['workerId']}"),
                      pw.Text("   Status: Absent"),
                      pw.Text("   Time: ${w['timestamp'] ?? '-'}"),
                      pw.SizedBox(height: 6),
                    ],
                  ),
                ),
                pw.SizedBox(height: 14),
                pw.Text(
                  "Non-Compliance (${nonCompliance.length})",
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                ...nonCompliance.map(
                      (w) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("- ${w['workerId']}"),
                      pw.Text("   Missing PPE: ${w['ppeIssue'] ?? '-'}"),
                      pw.Text("   Location: ${w['locationName'] ?? '-'}"),
                      pw.Text("   Time: ${w['timestamp'] ?? '-'}"),
                      pw.SizedBox(height: 6),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to generate report: $e")),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // SMALL HELPERS
  // ---------------------------------------------------------------------------
  Widget _statBlockFixed(String title, String count, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 36,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _periodPill(String p) {
    final active = period == p;
    final label = p[0].toUpperCase() + p.substring(1);
    return InkWell(
      onTap: () async {
        setState(() => period = p);
        await _loadSummary();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          color: active ? Colors.black : yellow,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _verticalDivider() => Container(height: 55, width: 1.6, color: Colors.black54);

  Widget _twoLabels(String a, String b) => Row(
    children: [
      Expanded(
        child: Text(a, style: const TextStyle(color: Colors.white)),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(b, style: const TextStyle(color: Colors.white)),
      ),
    ],
  );

  // ---------------------------------------------------------------------------
  // UPDATED: _twoInputs accepts controllers so values can be shown/edited
  // ---------------------------------------------------------------------------
  Widget _twoInputs(TextEditingController c1, TextEditingController c2) => Row(
    children: [
      Expanded(child: _inputBox(controller: c1)),
      const SizedBox(width: 12),
      Expanded(child: _inputBox(controller: c2)),
    ],
  );

  // ---------------------------------------------------------------------------
  // UPDATED: _inputBox shows controller text. When no controller provided it
  // returns an empty decorated box (backwards-compatible).
  // ---------------------------------------------------------------------------
  Widget _inputBox({TextEditingController? controller, double height = 40}) => Container(
    height: height,
    padding: controller != null ? const EdgeInsets.symmetric(horizontal: 10) : null,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: controller == null
        ? const SizedBox.shrink()
        : TextField(
      controller: controller,
      maxLines: height > 50 ? 4 : 1,
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
      ),
    ),
  );

  Widget _yellowButton(String text, {bool small = false}) => Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(vertical: small ? 8 : 14),
    decoration: BoxDecoration(
      color: yellow,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Center(
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}