import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import 'task_manager_page.dart';

class FeaturePage extends StatelessWidget {
  const FeaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> features = [
      {
        'icon': Icons.add_task_rounded,
        'title': 'Add, Edit & Delete Tasks',
        'desc': 'Easily manage all your to-dos with a simple interface.',
      },
      {
        'icon': Icons.alarm_rounded,
        'title': 'Smart Reminders',
        'desc': 'Get notified right on time with sound alerts.',
      },
      {
        'icon': Icons.download_rounded,
        'title': 'Download Task List',
        'desc': 'Save your tasks to a file anytime for offline access.',
      },
      {
        'icon': Icons.cloud_sync_rounded,
        'title': 'Backend Sync',
        'desc': 'Automatically sync tasks with the server in real time.',
      },
      {
        'icon': Icons.analytics_rounded,
        'title': 'Progress Overview',
        'desc': 'Track your productivity visually and stay on top.',
      },
    ];

    return Scaffold(
      appBar: const Navbar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 20),
            const Text(
              "✨ App Features",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Explore what makes your task management smarter and simpler.",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ...features.map((f) => AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withOpacity(0.15),
                  child: Icon(f['icon'] as IconData,
                      color: Colors.lightBlueAccent, size: 30),
                ),
                title: Text(
                  f['title'] as String, // ✅ safely cast to String
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  f['desc'] as String, // ✅ safely cast to String
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            )),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                      const TaskManagerPage(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        final tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: Curves.easeInOut));
                        return SlideTransition(position: animation.drive(tween), child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 500),
                    ),
                  );
                },

                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text("Start Using Now"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
