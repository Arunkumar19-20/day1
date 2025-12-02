import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../app_data.dart';

class RehabScreen extends StatelessWidget {
  const RehabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    const dailyGoal = 15000;
    double progress = (appData.steps / dailyGoal).clamp(0, 1);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgGradient = LinearGradient(
      colors: isDark
          ? [Colors.black, Colors.grey.shade900]
          : [Colors.teal.shade50, Colors.white],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Daily Rehab'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🏃‍♂️ Circular progress ring
            CircularPercentIndicator(
              radius: 130.0,
              lineWidth: 18.0,
              animation: true,
              animationDuration: 1200,
              percent: progress,
              circularStrokeCap: CircularStrokeCap.round,
              linearGradient: LinearGradient(
                colors: [Colors.teal, Colors.cyanAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              backgroundColor:
              isDark ? Colors.grey.shade800 : Colors.teal.shade100,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${(progress * 100).toStringAsFixed(0)}%",
                    style: GoogleFonts.poppins(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.tealAccent : Colors.teal.shade700,
                    ),
                  ),
                  Text(
                    "of goal",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 🦶 Steps count
            Text(
              'Steps today',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${appData.steps}',
              style: GoogleFonts.poppins(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.tealAccent : Colors.teal.shade800,
              ),
            ),
            const SizedBox(height: 30),

            // 🌈 Gradient progress bar (custom styled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Container(
                      height: 18,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.teal.shade100,
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        height: 18,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.teal, Colors.cyanAccent],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🏆 Goal info text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                progress < 1
                    ? "Keep going! You're just ${(dailyGoal - appData.steps).clamp(0, dailyGoal)} steps away from your goal."
                    : "Awesome! 🎉 You've reached your daily target!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: isDark ? Colors.white70 : Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 💬 Motivational quote
            AnimatedOpacity(
              duration: const Duration(seconds: 1),
              opacity: 1.0,
              child: Text(
                "“Small steps lead to big changes.”",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
