import 'dart:async';
import 'package:flutter/material.dart';

// --- MAIN APPLICATION ENTRY WORKFLOW ---

void main() {
  runApp(const FocuslyApp());
}

class FocuslyApp extends StatefulWidget {
  const FocuslyApp({Key? key}) : super(key: key);

  @override
  State<FocuslyApp> createState() => _FocuslyAppState();
}

class _FocuslyAppState extends State<FocuslyApp> {
  final AppStateManager stateManager = AppStateManager();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: stateManager,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Focusly',
          theme: stateManager.isDarkMode
              ? ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
             // Midnight Deep Blue Canvas
            primaryColor: const Color(0xFF8B5CF6),           // Vibrant Cyber Purple
            cardColor: const Color(0xFF171E2E),              // Navy Slate Card Contrast
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF8B5CF6),
              secondary: Color(0xFF3B82F6),                  // Electric Blue Accent
              surface: Color(0xFF171E2E),
            ),
            fontFamily: 'Roboto',
          )
              : ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
        // Crisp light grey canvas
            primaryColor: const Color(0xFF6D28D9),
            cardColor: Colors.white,
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6D28D9),
              secondary: Color(0xFF2563EB),
              surface: Colors.white,
            ),
            fontFamily: 'Roboto',
          ),
          home: InlineSplashScreen(stateManager: stateManager),
        );
      },
    );
  }
}

// --- CORE DATA MODELS ---

class Task {
  final String id;
  String title;
  bool isCompleted;
  String category;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.category = 'Study',
  });
}

class FocusSession {
  final DateTime timestamp;
  final int durationMinutes;

  FocusSession({
    required this.timestamp,
    required this.durationMinutes,
  });
}

class AppPreferences {
  int defaultPomodoroDuration;
  bool notificationsEnabled;
  bool strictMode;

  AppPreferences({
    this.defaultPomodoroDuration = 25,
    this.notificationsEnabled = true,
    this.strictMode = false,
  });
}

// --- CENTRAL APP STATE MANAGER ---

class AppStateManager extends ChangeNotifier {
  bool _isDarkMode = true;
  String _userName = "Developer Core";
  String _userRank = "Elite Focus Architect";

  final List<Task> _tasks = [
    Task(id: '1', title: 'Complete VFX Sand Simulation Analysis Paper', category: 'Academic'),
    Task(id: '2', title: 'Debug Flutter Navigation Stack State Issues', category: 'Coding'),
    Task(id: '3', title: 'Refactor OpenCV Bilateral Matrix Node Logic', category: 'Research'),
    Task(id: '4', title: 'Review Material 3 Design Guidelines', category: 'Design'),
  ];

  final List<FocusSession> _sessions = [
    FocusSession(timestamp: DateTime.now().subtract(const Duration(days: 2)), durationMinutes: 25),
    FocusSession(timestamp: DateTime.now().subtract(const Duration(days: 2)), durationMinutes: 25),
    FocusSession(timestamp: DateTime.now().subtract(const Duration(days: 1)), durationMinutes: 50),
    FocusSession(timestamp: DateTime.now(), durationMinutes: 25),
  ];

  final AppPreferences _preferences = AppPreferences();

  bool get isDarkMode => _isDarkMode;
  String get userName => _userName;
  String get userRank => _userRank;
  List<Task> get tasks => _tasks;
  List<FocusSession> get sessions => _sessions;
  AppPreferences get preferences => _preferences;

  int get totalFocusTime => _sessions.fold(0, (sum, item) => sum + item.durationMinutes);
  int get completedTasksCount => _tasks.where((t) => t.isCompleted).length;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void updateProfileName(String name) {
    if (name.trim().isNotEmpty) {
      _userName = name.trim();
      notifyListeners();
    }
  }

  void addTask(String title, String category) {
    if (title.trim().isNotEmpty) {
      _tasks.insert(0, Task(
        id: DateTime.now().toString(),
        title: title.trim(),
        category: category,
      ));
      notifyListeners();
    }
  }

  void toggleTaskStatus(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void logCompletedSession(int minutes) {
    _sessions.add(FocusSession(timestamp: DateTime.now(), durationMinutes: minutes));
    notifyListeners();
  }

  void updatePreferences({int? duration, bool? notify, bool? strict}) {
    if (duration != null) _preferences.defaultPomodoroDuration = duration;
    if (notify != null) _preferences.notificationsEnabled = notify;
    if (strict != null) _preferences.strictMode = strict;
    notifyListeners();
  }
}

// --- OFFICIAL GEOMETRIC TECH SPLASH SCREEN ---

class InlineSplashScreen extends StatefulWidget {
  final AppStateManager stateManager;
  const InlineSplashScreen({Key? key, required this.stateManager}) : super(key: key);

  @override
  State<InlineSplashScreen> createState() => _InlineSplashScreenState();
}

class _InlineSplashScreenState extends State<InlineSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NavigationHub(stateManager: widget.stateManager),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.stateManager.isDarkMode;

    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- PREMIUM GEOMETRIC TECH ICON ---
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFF334155), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.15),
                      blurRadius: 30,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Center(
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: Stack(
                      children: [
                        // Left Prism wing (Deep Cyber Purple)
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 32,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        // Right Prism wing (Electric Blue) with modular offset
                        Positioned(
                          right: 0,
                          top: 14,
                          bottom: 14,
                          child: Container(
                            width: 32,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        // Focal Core Lens (Overlapping glowing bridge)
                        Center(
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B0F19).withOpacity(0.85),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3B82F6).withOpacity(0.5),
                                  blurRadius: 8,
                                )
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.lens, size: 6, color: Color(0xFF60A5FA)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // --- POLISHED MINIMALIST TYPOGRAPHY ---
              Text(
                'FOCUSLY',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6.0,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 28,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6),
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// --- CORE NAVIGATION ARCHITECTURE LAYER ---

class NavigationHub extends StatefulWidget {
  final AppStateManager stateManager;
  const NavigationHub({Key? key, required this.stateManager}) : super(key: key);

  @override
  State<NavigationHub> createState() => _NavigationHubState();
}

class _NavigationHubState extends State<NavigationHub> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(
          stateManager: widget.stateManager,
          changeTab: (index) => setState(() => _currentIndex = index)),
      TimerScreen(stateManager: widget.stateManager),
      TaskScreen(stateManager: widget.stateManager),
      StatisticsScreen(stateManager: widget.stateManager),
      ProfileScreen(stateManager: widget.stateManager),
      SettingsScreen(stateManager: widget.stateManager),
    ];

    final isDark = widget.stateManager.isDarkMode;
    final activeColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFF6D28D9);
    final inactiveColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        elevation: 8,
        destinations: [
          NavigationDestination(
              icon: Icon(Icons.dashboard_rounded, color: _currentIndex == 0 ? activeColor : inactiveColor),
              label: 'Hub'),
          NavigationDestination(
              icon: Icon(Icons.timer_rounded, color: _currentIndex == 1 ? activeColor : inactiveColor),
              label: 'Timer'),
          NavigationDestination(
              icon: Icon(Icons.task_alt_rounded, color: _currentIndex == 2 ? activeColor : inactiveColor),
              label: 'Tasks'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart_rounded, color: _currentIndex == 3 ? activeColor : inactiveColor),
              label: 'Analytics'),
          NavigationDestination(
              icon: Icon(Icons.person_rounded, color: _currentIndex == 4 ? activeColor : inactiveColor),
              label: 'Profile'),
          NavigationDestination(
              icon: Icon(Icons.settings_suggest_rounded, color: _currentIndex == 5 ? activeColor : inactiveColor),
              label: 'Config'),
        ],
      ),
    );
  }
}

// --- 1. DASHBOARD SCREEN ---
class DashboardScreen extends StatelessWidget {
  final AppStateManager stateManager;
  final Function(int) changeTab;

  const DashboardScreen({Key? key, required this.stateManager, required this.changeTab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double progressRatio = stateManager.tasks.isEmpty
        ? 0.0
        : (stateManager.completedTasksCount / stateManager.tasks.length);

    final isDark = stateManager.isDarkMode;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final cardBg = isDark ? const Color(0xFF171E2E) : Colors.white;
    final subheadColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('System Dashboard,', style: TextStyle(color: subheadColor, fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text('Achieve Focus', style: TextStyle(color: titleColor, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF8B5CF6), width: 1.5),
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.bolt_rounded, color: Color(0xFF8B5CF6), size: 28),
                  )
                ],
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0), width: 1),
                  boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("TODAY'S STATE MONITOR", style: TextStyle(color: Color(0xFF8B5CF6), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${stateManager.totalFocusTime} Min', style: TextStyle(color: titleColor, fontSize: 36, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 2),
                            Text('Accumulated Focus', style: TextStyle(color: subheadColor, fontSize: 13)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${stateManager.completedTasksCount}/${stateManager.tasks.length}', style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 36, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 2),
                            Text('Tasks Cleared', style: TextStyle(color: subheadColor, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progressRatio,
                        minHeight: 10,

                        valueColor: const AppValueColor(Color(0xFF8B5CF6)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text('SYSTEM SHORTCUTS', style: TextStyle(color: subheadColor, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      cardBg: cardBg,
                      isDark: isDark,
                      textColor: titleColor,
                      subColor: subheadColor,
                      icon: Icons.timer_rounded,
                      title: 'Run Timer Engine',
                      subtitle: 'Start Pomodoro Session',
                      color: const Color(0xFF8B5CF6),
                      onTap: () => changeTab(1),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionCard(
                      cardBg: cardBg,
                      isDark: isDark,
                      textColor: titleColor,
                      subColor: subheadColor,
                      icon: Icons.task_alt_rounded,
                      title: 'Task Matrix',
                      subtitle: 'Manage Queue',
                      color: const Color(0xFF3B82F6),
                      onTap: () => changeTab(2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
      {required Color cardBg,
        required bool isDark,
        required Color textColor,
        required Color subColor,
        required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
        required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: subColor, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class AppValueColor extends Animation<Color?> {
  final Color color;
  const AppValueColor(this.color);

  @override void addListener(VoidCallback listener) {}
  @override void removeListener(VoidCallback listener) {}
  @override void addStatusListener(Function(AnimationStatus) listener) {}
  @override void removeStatusListener(Function(AnimationStatus) listener) {}
  @override AnimationStatus get status => AnimationStatus.completed;
  @override Color? get value => color;
}

// --- 2. TIMER SCREEN (WITH VOLT MASCOT MODULE) ---
class TimerScreen extends StatefulWidget {
  final AppStateManager stateManager;
  const TimerScreen({Key? key, required this.stateManager}) : super(key: key);

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? _ticker;
  int _secondsRemaining = 0;
  bool _isRunning = false;
  int _currentSessionLimitMinutes = 25;
  int _completedSessionsToday = 0;

  @override
  void initState() {
    super.initState();
    _resetToDuration(widget.stateManager.preferences.defaultPomodoroDuration);
  }

  void _resetToDuration(int mins) {
    _stopTicker();
    setState(() {
      _currentSessionLimitMinutes = mins;
      _secondsRemaining = mins * 60;
      _isRunning = false;
    });
  }

  void _toggleTimerEngine() {
    if (_isRunning) {
      _stopTicker();
    } else {
      setState(() => _isRunning = true);
      _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          setState(() => _secondsRemaining--);
        } else {
          _stopTicker();
          widget.stateManager.logCompletedSession(_currentSessionLimitMinutes);
          setState(() => _completedSessionsToday++);
          _showCompletionSheet();
        }
      });
    }
  }

  void _stopTicker() {
    _ticker?.cancel();
    setState(() => _isRunning = false);
  }

  void _clearTimer() {
    _resetToDuration(_currentSessionLimitMinutes);
  }

  void _showCompletionSheet() {
    final isDark = widget.stateManager.isDarkMode;
    showModalBottomSheet(
      context: context,

      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.celebration_rounded, color: Color(0xFF3B82F6), size: 64),
              const SizedBox(height: 16),
              Text('Focus Window Complete!', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Excellent work. $_currentSessionLimitMinutes minutes logged.', textAlign: TextAlign.center, style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569))),
              const SizedBox(height: 24),
              ElevatedButton(

                onPressed: () => Navigator.pop(context),
                child: const Text('Acknowledge Engine Output', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        );
      },
    );
  }

  String _formatOutputString() {
    int m = _secondsRemaining ~/ 60;
    int s = _secondsRemaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.stateManager.isDarkMode;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subheadColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),

                      // --- VOLT MASCOT CHASSIS ---
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF171E2E) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _isRunning ? const Color(0xFF8B5CF6) : Colors.transparent, width: 1.5)
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                _isRunning ? ' 🤖⚡ (*_*) ' : ' 🤖💤 (-_-) ',
                                style: const TextStyle(fontSize: 22)
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isRunning ? 'Volt is monitoring focus...' : 'Volt is resting...',
                              style: TextStyle(color: _isRunning ? const Color(0xFF8B5CF6) : subheadColor, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 240,
                            height: 240,
                            child: CircularProgressIndicator(
                              value: _secondsRemaining / (_currentSessionLimitMinutes * 60),
                              strokeWidth: 8,

                              valueColor: const AppValueColor(Color(0xFF8B5CF6)),
                            ),
                          ),
                          Text(
                            _formatOutputString(),
                            style: TextStyle(
                                color: titleColor,
                                fontSize: 50,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [25, 45, 60].map((m) {
                          bool active = _currentSessionLimitMinutes == m;
                          return ActionChip(
                            label: Text('$m Min'),

                            labelStyle: TextStyle(color: active ? Colors.white : subheadColor, fontWeight: FontWeight.bold),
                            onPressed: () => _resetToDuration(m),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton.filledTonal(
                            iconSize: 28,
                            padding: const EdgeInsets.all(14),
                            icon: Icon(Icons.refresh_rounded, color: titleColor),
                            onPressed: _clearTimer,
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(

                              fixedSize: const Size(130, 56),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: _toggleTimerEngine,
                            child: Text(_isRunning ? 'PAUSE' : 'START', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text('Completed Sessions Today: $_completedSessionsToday', style: TextStyle(color: subheadColor, fontSize: 13)),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// --- 3. TASK SCREEN (WITH INTERACTIVE CATEGORY MATRIX FILTER) ---
class TaskScreen extends StatefulWidget {
  final AppStateManager stateManager;
  const TaskScreen({Key? key, required this.stateManager}) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TextEditingController _taskInputController = TextEditingController();
  String _selectedFilterCategory = 'All';
  String _newItemCategory = 'Academic';

  final List<String> _categories = ['All', 'Academic', 'Coding', 'Research', 'Design'];
  final List<String> _creationCategories = ['Academic', 'Coding', 'Research', 'Design'];

  void _triggerTaskAdditionWorkflow() {
    final isDark = widget.stateManager.isDarkMode;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24, left: 24, right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Queue New Execution Target', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _taskInputController,
                    style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: 'Enter task criteria...',
                      hintStyle: const TextStyle(color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('ASSIGN MATRIX TAG', style: TextStyle(color: Color(0xFF8B5CF6), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    children: _creationCategories.map((cat) {
                      bool isSelected = _newItemCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: const Color(0xFF8B5CF6),
                        labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87)),
                        onSelected: (accepted) {
                          if (accepted) setModalState(() => _newItemCategory = cat);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(

                    onPressed: () {
                      if (_taskInputController.text.trim().isNotEmpty) {
                        widget.stateManager.addTask(_taskInputController.text.trim(), _newItemCategory);
                        _taskInputController.clear();
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Inject Into Matrix', style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.stateManager.isDarkMode;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);

    final filteredTasks = _selectedFilterCategory == 'All'
        ? widget.stateManager.tasks
        : widget.stateManager.tasks.where((t) => t.category == _selectedFilterCategory).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Task Matrix', style: TextStyle(color: titleColor, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  IconButton.filled(

                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    onPressed: _triggerTaskAdditionWorkflow,
                  )
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _categories.map((category) {
                    bool isSelected = _selectedFilterCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        selectedColor: const Color(0xFF8B5CF6).withOpacity(0.2),
                        checkmarkColor: const Color(0xFF8B5CF6),
                        side: BorderSide(color: isSelected ? const Color(0xFF8B5CF6) : Colors.transparent),
                        labelStyle: TextStyle(
                          color: isSelected ? const Color(0xFF8B5CF6) : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedFilterCategory = category);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: filteredTasks.isEmpty
                    ? const Center(child: Text('No active elements match this category template.', style: TextStyle(color: Color(0xFF64748B))))
                    : ListView.builder(
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF171E2E) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: task.isCompleted,
                            activeColor: const Color(0xFF3B82F6),
                            onChanged: (_) => widget.stateManager.toggleTaskStatus(task.id),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(task.title, style: TextStyle(color: titleColor, fontSize: 15, decoration: task.isCompleted ? TextDecoration.lineThrough : null)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                  child: Text(task.category.toUpperCase(), style: const TextStyle(color: Color(0xFF8B5CF6), fontSize: 9, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                            onPressed: () => widget.stateManager.deleteTask(task.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 4. STATISTICS SCREEN ---
class StatisticsScreen extends StatelessWidget {
  final AppStateManager stateManager;
  const StatisticsScreen({Key? key, required this.stateManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = stateManager.isDarkMode;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subheadColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Analytics Data', style: TextStyle(color: titleColor, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildMetricTile(isDark, titleColor, 'Total Metrics Logged', '${stateManager.totalFocusTime}m', const Color(0xFF8B5CF6))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMetricTile(isDark, titleColor, 'Velocity Factor', '${stateManager.completedTasksCount} Complete', const Color(0xFF3B82F6))),
                ],
              ),
              const SizedBox(height: 32),
              Text('WEEKLY PRODUCTIVITY VELOCITY', style: TextStyle(color: subheadColor, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
              const SizedBox(height: 16),
              Container(
                height: 180,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF171E2E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                  boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildGraphBar(isDark, 'Mon', 25),
                    _buildGraphBar(isDark, 'Tue', 50),
                    _buildGraphBar(isDark, 'Wed', 0),
                    _buildGraphBar(isDark, 'Thu', 75),
                    _buildGraphBar(isDark, 'Fri', 40),
                    _buildGraphBar(isDark, 'Sat', 100),
                    _buildGraphBar(isDark, 'Sun', 15),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(bool isDark, Color titleColor, String header, String val, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(header, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          const SizedBox(height: 12),
          Text(val, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGraphBar(bool isDark, String day, double structuralHeightPercentage) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            width: 14,
            decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(4)),
            alignment: Alignment.bottomCenter,
            child: Container(
              height: structuralHeightPercentage,
              width: 14,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
      ],
    );
  }
}

// --- 5. USER PROFILE SCREEN ---
class ProfileScreen extends StatelessWidget {
  final AppStateManager stateManager;
  const ProfileScreen({Key? key, required this.stateManager}) : super(key: key);

  void _showEditNameDialog(BuildContext context) {
    final controller = TextEditingController(text: stateManager.userName);
    final isDark = stateManager.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(

        title: Text('Edit Profile Name', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A))),
        content: TextField(
          controller: controller,
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: "Enter name",
            fillColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF1F5F9),
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(

            onPressed: () {
              stateManager.updateProfileName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = stateManager.isDarkMode;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final containerBg = isDark ? const Color(0xFF171E2E) : Colors.white;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text('User Profile', style: TextStyle(color: titleColor, fontSize: 32, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 32),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,

                    child: CircleAvatar(
                      radius: 56,

                      child: Icon(Icons.person_rounded, size: 60, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                    ),
                  ),
                  IconButton.filled(

                    icon: const Icon(Icons.edit_rounded, size: 18, color: Colors.white),
                    onPressed: () => _showEditNameDialog(context),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Text(stateManager.userName, style: TextStyle(color: titleColor, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(stateManager.userRank, style: const TextStyle(color: Color(0xFF8B5CF6), fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: containerBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildProfileStatRow(isDark, Icons.bolt_rounded, 'Focus Efficiency', '94.2%', const Color(0xFF8B5CF6)),
                    Divider(height: 24, color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                    _buildProfileStatRow(isDark, Icons.timer_rounded, 'Total Focus Windows', '${stateManager.sessions.length} Blocks', const Color(0xFF3B82F6)),
                    Divider(height: 24, color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                    _buildProfileStatRow(isDark, Icons.task_alt_rounded, 'Current Stack Size', '${stateManager.tasks.length} Active', const Color(0xFF64748B)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileStatRow(bool isDark, IconData icon, String title, String val, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 16),
        Text(title, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(val, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// --- 6. SETTINGS SCREEN ---
class SettingsScreen extends StatelessWidget {
  final AppStateManager stateManager;
  const SettingsScreen({Key? key, required this.stateManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = stateManager.isDarkMode;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Text('Configuration', style: TextStyle(color: titleColor, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            const SizedBox(height: 24),
            _buildSettingHeader('Appearance Matrix'),
            SwitchListTile(
              title: Text('Dark Mode Canvas', style: TextStyle(color: titleColor, fontWeight: FontWeight.w600)),
              subtitle: const Text('Toggle between light canvas environments and deep dark interfaces.', style: TextStyle(color: Color(0xFF94A3B8))),
              value: stateManager.isDarkMode,
              activeColor: const Color(0xFF3B82F6),
              onChanged: (val) => stateManager.toggleTheme(),
            ),
            Divider(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0), height: 32),
            _buildSettingHeader('Timer Configurations'),
            ListTile(
              title: Text('Default Focus Window', style: TextStyle(color: titleColor, fontWeight: FontWeight.w600)),
              subtitle: Text('${stateManager.preferences.defaultPomodoroDuration} Minutes per block', style: const TextStyle(color: Color(0xFF94A3B8))),
              trailing: const Icon(Icons.arrow_drop_down_circle_rounded, color: Color(0xFF8B5CF6)),
              onTap: () {
                int current = stateManager.preferences.defaultPomodoroDuration;
                int next = current == 25 ? 45 : (current == 45 ? 60 : 25);
                stateManager.updatePreferences(duration: next);
              },
            ),
            Divider(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0), height: 32),
            _buildSettingHeader('System Security & Alerts'),
            SwitchListTile(
              title: Text('Execution Sound Alerts', style: TextStyle(color: titleColor, fontWeight: FontWeight.w600)),
              subtitle: const Text('Trigger audio notifications on ticker depletion.', style: TextStyle(color: Color(0xFF94A3B8))),
              value: stateManager.preferences.notificationsEnabled,
              activeColor: const Color(0xFF3B82F6),
              onChanged: (val) => stateManager.updatePreferences(notify: val),
            ),
            SwitchListTile(
              title: Text('Deep Work Lockout (Strict Mode)', style: TextStyle(color: titleColor, fontWeight: FontWeight.w600)),
              subtitle: const Text('Prevents cancellation of running timer engines.', style: TextStyle(color: Color(0xFF94A3B8))),
              value: stateManager.preferences.strictMode,
              activeColor: const Color(0xFF3B82F6),
              onChanged: (val) => stateManager.updatePreferences(strict: val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(text.toUpperCase(), style: const TextStyle(color: Color(0xFF8B5CF6), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
    );
  }
}
