import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_settings.dart';
import '../app_data.dart';
import '../widgets/micro_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<FlSpot> getAnimatedData(List<FlSpot> data, double t) {
    return data
        .map((spot) => FlSpot(spot.x, spot.y * (0.8 + 0.2 * t)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final appSettings = Provider.of<AppSettings>(context);
    final isDark = appSettings.useDarkMode;

    final bgGradient = LinearGradient(
      colors: isDark
          ? [Colors.black, Colors.grey.shade900]
          : [Colors.teal.shade50, Colors.white],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🧠 Animated title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Smart Crutch",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.tealAccent : Colors.teal.shade700,
                      ),
                    ),
                    Icon(
                      Icons.dashboard_rounded,
                      color: isDark ? Colors.tealAccent : Colors.teal,
                      size: 32,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Dashboard Overview",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),

                // 📊 Animated Line Chart Card
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final animatedData =
                    getAnimatedData(appData.stepsData, _controller.value);
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Card(
                        color: isDark
                            ? Colors.grey.shade900
                            : Colors.white.withOpacity(0.95),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        elevation: 6,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Weekly Steps Trend",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.teal.shade700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 220,
                                child: LineChart(
                                  LineChartData(
                                    gridData: FlGridData(show: false),
                                    titlesData: FlTitlesData(
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 22,
                                          getTitlesWidget: (value, _) => Text(
                                            'D${value.toInt() % 7 + 1}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          getTitlesWidget: (value, _) => Text(
                                            value.toInt().toString(),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.black54,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: animatedData,
                                        isCurved: true,
                                        barWidth: 4,
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.tealAccent,
                                            Colors.cyanAccent.shade200,
                                          ],
                                        ),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.tealAccent
                                                  .withOpacity(0.3),
                                              Colors.transparent,
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // 🧾 Metric Cards (Pulse shimmer)
                Row(
                  children: [
                    Expanded(
                      child: MicroCard(
                        title: 'Steps',
                        value: '${appData.steps}',
                        colors: [Colors.teal, Colors.cyan],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MicroCard(
                        title: 'Distance',
                        value: '${appData.distance.toStringAsFixed(2)} km',
                        colors: [Colors.orange, Colors.deepOrangeAccent],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: MicroCard(
                        title: 'Battery',
                        value: '${appData.battery}%',
                        colors: [Colors.green, Colors.lightGreenAccent],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MicroCard(
                        title: 'Alerts',
                        value: '${appData.alerts.length}',
                        colors: [Colors.redAccent, Colors.pinkAccent],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 🧾 Recent Activity
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  color: isDark ? Colors.grey.shade900 : Colors.white,
                  child: ListTile(
                    leading: Icon(
                      Icons.notifications_active_rounded,
                      color: isDark ? Colors.tealAccent : Colors.teal,
                      size: 28,
                    ),
                    title: Text(
                      'Recent Activity',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    subtitle: appData.alerts.isEmpty
                        ? Text(
                      'No alerts yet 🎉',
                      style: TextStyle(
                          color: isDark
                              ? Colors.white54
                              : Colors.grey.shade700),
                    )
                        : Text(
                      appData.alerts.last,
                      style: TextStyle(
                          color: isDark
                              ? Colors.white70
                              : Colors.grey.shade800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
