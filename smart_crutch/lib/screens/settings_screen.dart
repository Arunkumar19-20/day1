import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);
    final isDark = settings.useDarkMode;

    Widget buildSectionTitle(String title) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 1.2,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      );
    }

    Widget buildCard({required Widget child, double? height}) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        height: height,
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
            colors: [Colors.grey[850]!, Colors.grey[800]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : LinearGradient(
            colors: [Colors.white, Colors.teal.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black54 : Colors.grey.shade300,
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: child,
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.teal.shade50,
      appBar: AppBar(
        title: const Text('⚙️ Settings'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.teal,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            buildSectionTitle("Appearance"),
            buildCard(
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    title: const Text(
                      'Dark Mode',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "Toggle between light and dark mode",
                      style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                    ),
                    value: settings.useDarkMode,
                    onChanged: (_) => settings.toggleDarkMode(),
                    secondary: Icon(
                      isDark ? Icons.nights_stay_rounded : Icons.wb_sunny_rounded,
                      color: isDark ? Colors.amberAccent : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [Colors.grey[800]!, Colors.grey[700]!]
                            : [Colors.teal.shade100, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        isDark ? "Dark Mode Preview" : "Light Mode Preview",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            // Alerts Section
            buildSectionTitle("Alerts"),
            buildCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.volume_up_rounded, color: Colors.teal),
                    title: const Text(
                      "Alert Volume",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Slider(
                      value: settings.alertVolume,
                      min: 0,
                      max: 1,
                      divisions: 10,
                      label: "${(settings.alertVolume * 100).toInt()}%",
                      activeColor: Colors.teal,
                      onChanged: (v) => settings.setAlertVolume(v),
                    ),
                    trailing: Text(
                      "${(settings.alertVolume * 100).toInt()}%",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications_active_rounded, color: Colors.orange),
                    title: const Text(
                      "Test Alert",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Test alert triggered!")),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Data Section
            buildSectionTitle("Data & Backup"),
            buildCard(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Export logs not implemented')));
                    },
                    icon: const Icon(Icons.upload_file_rounded),
                    label: const Text('Export Logs'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Import logs not implemented')));
                    },
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Import Logs'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: BorderSide(color: isDark ? Colors.white70 : Colors.teal),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      settings.resetSettings();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings reset to default')),
                      );
                    },
                    icon: const Icon(Icons.restore_rounded),
                    label: const Text('Reset to Default'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
