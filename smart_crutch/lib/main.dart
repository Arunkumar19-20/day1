import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_settings.dart';
import 'app_data.dart';
import 'screens/dashboard_screen.dart';
import 'screens/rehab_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/careteam_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettings()),
        ChangeNotifierProvider(create: (_) => AppData()),
      ],
      child: const SmartCrutchApp(),
    ),
  );
}

class SmartCrutchApp extends StatelessWidget {
  const SmartCrutchApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);
    return MaterialApp(
      title: 'Smart Crutch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: settings.useDarkMode ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: settings.useDarkMode ? Colors.grey[900] : Colors.grey[50],
      ),
      home: const MainTabs(),
    );
  }
}

class MainTabs extends StatefulWidget {
  const MainTabs({super.key});
  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _index = 0;
  final List<Widget> _screens = const [
    DashboardScreen(),
    RehabScreen(),
    AlertsScreen(),
    CareTeamScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Rehab'),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Care'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
