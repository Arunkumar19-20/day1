// lib/main.dart
// OneHealth - Medium Flutter App Scaffold (fixed & runnable)
// Replace placeholders and TODOs with real integrations as you build out features.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(OneHealthApp());
}

// Simple Role enum
enum UserRole { CHC, Vet, District, State, Admin }

// App-level state using ChangeNotifier
class AppState extends ChangeNotifier {
  UserRole role;
  String username;
  bool online = true;
  DateTime lastSync = DateTime.now();

  AppState({this.role = UserRole.CHC, this.username = 'Field Worker'});

  void setRole(UserRole r) {
    role = r;
    notifyListeners();
  }

  void setOnline(bool val) {
    online = val;
    lastSync = DateTime.now();
    notifyListeners();
  }

  void updateLastSync() {
    lastSync = DateTime.now();
    notifyListeners();
  }
}

class OneHealthApp extends StatelessWidget {
  final AppState appState = AppState();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: MaterialApp(
        title: 'OASIS - OneHealth',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: AppRoot(),
      ),
    );
  }
}

class AppRoot extends StatefulWidget {
  @override
  _AppRootState createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // simulate periodic sync changes for the demo
    _timer = Timer.periodic(Duration(seconds: 60), (_) {
      Provider.of<AppState>(context, listen: false).updateLastSync();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold();
  }
}

// --- Main scaffold with top nav, global status bar, and drawer ---
class MainScaffold extends StatefulWidget {
  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    DashboardScreen(),
    CaseReportingScreen(),
    MapScreen(),
    AlertsScreen(),
    AdminScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Case Reporting',
    'Map',
    'Alerts',
    'Admin',
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            FlutterLogo(),
            const SizedBox(width: 8),
            const Text('OASIS'),
            const SizedBox(width: 16),
            Expanded(child: Text(_titles[_selectedIndex])),
            IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () => _openKB(context),
              tooltip: 'Contextual help',
            ),
            IconButton(
              icon: Icon(Icons.notifications_none),
              onPressed: () => _openNotifications(context),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text('Log case'),
              style: ElevatedButton.styleFrom(elevation: 0),
              onPressed: () => _goToCaseForm(context),
            ),
            const SizedBox(width: 8),
            _buildProfileMenu(appState),
          ],
        ),
        toolbarHeight: 64,
      ),
      body: Column(
        children: [
          _buildGlobalStatusBar(appState),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.note_add), label: 'Report'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        ],
      ),
      drawer: _buildDrawer(context, appState),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Quick Log'),
        icon: Icon(Icons.add_location_alt),
        onPressed: () => _goToCaseForm(context),
      ),
    );
  }

  Widget _buildGlobalStatusBar(AppState appState) {
    return Material(
      elevation: 2,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: Colors.grey[100],
        child: Row(
          children: [
            const Text('Sync: '),
            _buildSyncChip(appState.online),
            const SizedBox(width: 16),
            Text('Last sync: ${appState.lastSync.toLocal().toString().split('.').first}'),
            Spacer(),
            Text('Breadcrumbs > ${DateTime.now().toIso8601String().substring(0, 10)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncChip(bool online) {
    return Chip(label: Text(online ? 'Online' : 'Offline'));
  }

  void _openKB(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('Knowledge Base'),
        content: Text('Short tips and link to KB (placeholder).'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Close'))],
      ),
    );
  }

  void _openNotifications(BuildContext ctx) {
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => NotificationsScreen()));
  }

  void _goToCaseForm(BuildContext ctx) {
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => CaseReportingScreen()));
  }

  Widget _buildProfileMenu(AppState appState) {
    return PopupMenuButton<String>(
      onSelected: (v) {
        if (v == 'logout') {
          // TODO: implement logout
        } else if (v == 'switch') {
          _showRoleSwitchDialog();
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(child: Text('${appState.username} (${appState.role.name})')),
        PopupMenuItem(value: 'switch', child: Text('Switch role')),
        PopupMenuItem(value: 'logout', child: Text('Logout')),
      ],
      child: Row(
        children: [
          CircleAvatar(child: Text(appState.username.isNotEmpty ? appState.username[0] : 'U')),
          const SizedBox(width: 8),
          Text(appState.username),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AppState appState) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 28, child: Text(appState.username.isNotEmpty ? appState.username[0] : 'U')),
                const SizedBox(height: 8),
                Text(appState.username, style: TextStyle(fontSize: 18)),
                Text(appState.role.name),
              ],
            ),
          ),
          ListTile(leading: Icon(Icons.dashboard), title: Text('Dashboard'), onTap: () => setState(() => _selectedIndex = 0)),
          ListTile(leading: Icon(Icons.note_add), title: Text('Log Case'), onTap: () => setState(() => _selectedIndex = 1)),
          ListTile(leading: Icon(Icons.map), title: Text('Map'), onTap: () => setState(() => _selectedIndex = 2)),
          ListTile(leading: Icon(Icons.settings), title: Text('Settings')),
        ],
      ),
    );
  }

  void _showRoleSwitchDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Switch Role'),
          content: Consumer<AppState>(builder: (context, appState, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: UserRole.values
                  .map((r) => RadioListTile<UserRole>(
                title: Text(r.name),
                value: r,
                groupValue: appState.role,
                onChanged: (v) {
                  if (v != null) {
                    appState.setRole(v);
                    Navigator.pop(context);
                  }
                },
              ))
                  .toList(),
            );
          }),
        );
      },
    );
  }
}

// --- Dashboard Screen (role-aware) ---
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero summary cards
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _SummaryCard('Suspected cases (24h)', '12', onTap: () {}),
              _SummaryCard('Active hotspots', '3', onTap: () {}),
              _SummaryCard('New animal cases', '5', onTap: () {}),
              _SummaryCard('Alerts pending', '2', onTap: () {}),
            ],
          ),
          SizedBox(height: 12),
          // Quick actions
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CaseReportingScreen())),
                icon: Icon(Icons.person_add),
                label: Text('Log human case'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CaseReportingScreen(initialMode: 'animal'))),
                icon: Icon(Icons.pets),
                label: Text('Log animal case'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MapScreen())),
                icon: Icon(Icons.map),
                label: Text('Open map'),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Mini map placeholder
          Container(
            height: 160,
            color: Colors.grey[200],
            child: Center(child: Text('Mini map snapshot (tap to open full map)')),
          ),
          SizedBox(height: 12),
          Text('Recent activity', style: Theme.of(context).textTheme.titleLarge),
          Text('Model confidence', style: Theme.of(context).textTheme.titleLarge),

          _ModelConfidenceWidget(),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback? onTap;
  _SummaryCard(this.title, this.value, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Container(
          width: 180,
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
              SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      'Case #123 submitted (village X)',
      'Alert triggered for district Y',
      'Model detected anomaly in region Z',
    ];
    return Column(
      children: items
          .map((s) => ListTile(
        leading: Icon(Icons.circle, size: 12),
        title: Text(s),
        subtitle: Text('2h ago'),
      ))
          .toList(),
    );
  }
}

class _ModelConfidenceWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final entries = [
      {'area': 'Block A', 'prob': 0.72},
      {'area': 'Block B', 'prob': 0.51},
      {'area': 'Block C', 'prob': 0.32},
    ];
    return Column(
      children: entries
          .map((e) => ListTile(
        title: Text('${e['area']} - ${((e['prob'] as double) * 100).toStringAsFixed(0)}%'),

        subtitle: Text('Top features: rainfall ↑, nearby animal cases'),
      ))
          .toList(),
    );
  }
}

// --- Case Reporting Screen (single page with tabs) ---
class CaseReportingScreen extends StatefulWidget {
  final String initialMode;
  CaseReportingScreen({this.initialMode = 'human'});
  @override
  _CaseReportingScreenState createState() => _CaseReportingScreenState();
}

class _CaseReportingScreenState extends State<CaseReportingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String mode = 'human';

  @override
  void initState() {
    super.initState();
    mode = widget.initialMode;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Case Reporting')),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [Tab(text: 'Human'), Tab(text: 'Animal'), Tab(text: 'Bulk')],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                CaseForm(mode: 'human'),
                CaseForm(mode: 'animal'),
                BulkImportScreen(),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CaseForm extends StatefulWidget {
  final String mode; // 'human' or 'animal'
  CaseForm({this.mode = 'human'});
  @override
  _CaseFormState createState() => _CaseFormState();
}

class _CaseFormState extends State<CaseForm> {
  final _formKey = GlobalKey<FormState>();
  String species = 'cattle';
  final TextEditingController _symptomsController = TextEditingController();
  bool urgent = false;
  String escalation = 'None';
  final TextEditingController _locationController = TextEditingController();

  @override
  void dispose() {
    _symptomsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(12),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Location'),
            Row(children: [
              Expanded(child: TextFormField(controller: _locationController, decoration: InputDecoration(hintText: 'Tap to pick on map or auto-fill GPS'))),
              IconButton(icon: Icon(Icons.my_location), onPressed: () {}),
            ]),
            const SizedBox(height: 8),
            const Text('Date / Time of onset'),
            TextFormField(initialValue: DateTime.now().toIso8601String()),
            const SizedBox(height: 8),
            if (widget.mode == 'animal') ...[
              const Text('Species'),
              DropdownButton<String>(
                value: species,
                items: ['cattle', 'goat', 'sheep', 'pig', 'dog', 'other'].map((s) => DropdownMenuItem(child: Text(s), value: s)).toList(),
                onChanged: (v) => setState(() => species = v ?? 'cattle'),
              ),
            ],
            const SizedBox(height: 8),
            const Text('Symptoms'),
            Row(children: [
              Expanded(child: TextFormField(controller: _symptomsController, decoration: InputDecoration(hintText: 'Type or use voice'))),
              IconButton(icon: Icon(Icons.mic), onPressed: _startVoiceASR),
            ]),
            const SizedBox(height: 8),
            const Text('Upload images / attachments'),
            Row(children: [IconButton(icon: Icon(Icons.camera_alt), onPressed: () {}), IconButton(icon: Icon(Icons.attach_file), onPressed: () {})]),
            const SizedBox(height: 8),
            const Text('Auto-suspected diagnosis (classifier)'),
            Card(child: ListTile(title: Text('Brucellosis'), subtitle: Text('Confidence: 78% — Keywords: fever, abortion'))),
            const SizedBox(height: 8),
            Row(children: [
              const Text('Escalation:'),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: escalation,
                items: ['None', 'Local Vet', 'District Officer'].map((e) => DropdownMenuItem(child: Text(e), value: e)).toList(),
                onChanged: (v) => setState(() => escalation = v ?? 'None'),
              ),
            ]),
            SwitchListTile(title: const Text('Urgent'), value: urgent, onChanged: (v) => setState(() => urgent = v)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _submit, child: const Text('Submit'))
          ],
        ),
      ),
    );
  }

  void _startVoiceASR() {
    // TODO: integrate speech_to_text or Whisper
    setState(() {
      _symptomsController.text = 'fever, cough, sudden abortions';
    });
  }

  void _submit() {
    if (_formKey.currentState != null) {
      final caseId = 'CASE-' + DateTime.now().millisecondsSinceEpoch.toString();
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Submitted'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [Text('Case ID: $caseId'), SizedBox(height: 8), Text('Saved locally — will sync')]),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
    }
  }
}

class BulkImportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Bulk import (CSV) — placeholder'));
  }
}

// --- Map Screen (placeholder) ---
class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Outbreak Map')),
      body: Column(children: [
        // Controls
        Padding(
          padding: EdgeInsets.all(8),
          child: Row(children: [
            DropdownButton<String>(
              value: 'heatmap',
              items: ['cases', 'heatmap', 'predicted risk', 'boundaries'].map((e) => DropdownMenuItem(child: Text(e), value: e)).toList(),
              onChanged: (_) {},
            ),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: () {}, child: const Text('Export')),
          ]),
        ),
        Expanded(child: Container(color: Colors.grey[200], child: const Center(child: Text('Map canvas (Mapbox / Leaflet)')))),
      ]),
    );
  }
}

// --- Alerts Screen ---
class AlertsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final alerts = [
      {'title': 'Cluster detected in Block A', 'priority': 'High'},
      {'title': 'Multiple abortions reported', 'priority': 'Medium'},
    ];
    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: alerts.length,
      itemBuilder: (_, i) => Card(
        child: ListTile(
          leading: Icon(Icons.warning),
          title: Text(alerts[i]['title']!),
          subtitle: Text('Priority: ${alerts[i]['priority']}'),
          trailing: ElevatedButton(child: Text('Acknowledge'), onPressed: () {}),
        ),
      ),
    );
  }
}

// --- Notifications ---
class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Notifications')), body: const Center(child: Text('Notifications list')));
  }
}

// --- Admin Screen (role-based features) ---
class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    if (appState.role != UserRole.Admin) {
      return const Center(child: Text('Admin features are restricted.'));
    }
    return ListView(padding: EdgeInsets.all(12), children: const [
      ListTile(title: Text('User Management'), leading: Icon(Icons.people)),
      ListTile(title: Text('Facilities'), leading: Icon(Icons.business)),
      ListTile(title: Text('Integrations'), leading: Icon(Icons.link)),
      ListTile(title: Text('Model Ops'), leading: Icon(Icons.device_hub)),
    ]);
  }
}

// --- Simple service stubs (API, Local DB, Auth) ---
class ApiService {
  Future<Map<String, dynamic>> postCase(Map<String, dynamic> payload) async {
    await Future.delayed(Duration(seconds: 1));
    return {'success': true, 'case_id': 'CASE-123'};
  }
}

class LocalDb {
  Future<void> saveCase(Map<String, dynamic> c) async {}
}

class AuthService {
  Future<bool> login(String username, String password) async {
    await Future.delayed(Duration(milliseconds: 400));
    return true;
  }
}
