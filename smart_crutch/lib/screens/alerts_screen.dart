import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_settings.dart';
import '../app_data.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildFrostedCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? color,
    bool pulsate = false,
    VoidCallback? action,
  }) {
    final appSettings = Provider.of<AppSettings>(context, listen: false);
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: appSettings.useDarkMode
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (color ?? Colors.teal).withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (color ?? Colors.teal).withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            leading: Icon(icon, size: 36, color: color ?? Colors.teal),
            title: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: appSettings.useDarkMode
                    ? Colors.white
                    : Colors.grey.shade900,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: appSettings.useDarkMode
                    ? Colors.white70
                    : Colors.grey.shade700,
              ),
            ),
            trailing: action != null
                ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color ?? Colors.teal,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: action,
              child: const Text("Test"),
            )
                : null,
          ),
        ),
      ),
    );

    return pulsate
        ? ScaleTransition(scale: _pulseAnimation, child: card)
        : card;
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final appSettings = Provider.of<AppSettings>(context);
    final isDark = appSettings.useDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Safety Alerts"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.black, Colors.grey.shade900]
                : [Colors.teal.shade100, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 🔥 Animated Lottie Header
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.teal, Colors.cyanAccent],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/lottie/fall_alert.json',
                        height: 100,
                        repeat: true,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Monitoring your safety in real-time 🛡️",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ⚠️ Fall Detection Card
                _buildFrostedCard(
                  icon: Icons.warning_amber_rounded,
                  title: "Fall Detection",
                  subtitle: appData.alerts.isEmpty
                      ? "No active fall alerts."
                      : appData.alerts.last.contains('Fall')
                      ? "🚨 Fall detected! Emergency response activated."
                      : "No active fall alerts.",
                  color: Colors.redAccent,
                  pulsate: appData.alerts.isNotEmpty &&
                      appData.alerts.last.contains('Fall'),
                  action: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Test fall alert triggered."),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 🔋 Battery Card
                _buildFrostedCard(
                  icon: Icons.battery_alert_rounded,
                  title: "Battery Status",
                  subtitle: "Crutch battery at ${appData.battery}%",
                  color: appData.battery < 20
                      ? Colors.orangeAccent
                      : Colors.tealAccent,
                  pulsate: appData.battery < 20,
                ),
                const SizedBox(height: 16),

                // 🔔 Custom Alerts
                ...appData.alerts
                    .where((a) => !a.contains('Fall'))
                    .map(
                      (alert) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildFrostedCard(
                      icon: Icons.notifications_active_rounded,
                      title: "Alert",
                      subtitle: alert,
                      color: Colors.cyanAccent,
                    ),
                  ),
                )
                    .toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
