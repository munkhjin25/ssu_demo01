import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart';
import 'dashboard_screen.dart'; // Reuses AppValueColor helper clean layout

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
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.celebration_rounded, color: Color(0xFF10B981), size: 64),
              const SizedBox(height: 16),
              const Text('Focus Window Complete!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Excellent work. $_currentSessionLimitMinutes minutes logged securely to your performance graph.', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF94A3B8))),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), minimumSize: const Size(double.infinity, 50)),
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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('FOCUS ENGINE ACTIVE', style: TextStyle(color: Color(0xFF6366F1), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2.0)),
                const SizedBox(height: 40),

                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 260,
                      height: 260,
                      child: CircularProgressIndicator(
                        value: _secondsRemaining / (_currentSessionLimitMinutes * 60),
                        strokeWidth: 8,
                        backgroundColor: const Color(0xFF1E293B),
                        valueColor: const AppValueColor(Color(0xFF6366F1)),
                      ),
                    ),
                    Text(
                      _formatOutputString(),
                      style: const TextStyle(color: Colors.white, fontSize: 54, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [25, 45, 60].map((m) {
                    bool active = _currentSessionLimitMinutes == m;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: ActionChip(
                        label: Text('$m Min'),
                        backgroundColor: active ? const Color(0xFF6366F1) : const Color(0xFF1E293B),
                        labelStyle: TextStyle(color: active ? Colors.white : const Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                        onPressed: () => _resetToDuration(m),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 48),

                Row(
                  mainAxisAlignment: Main => MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      iconSize: 32,
                      padding: const EdgeInsets.all(16),
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                      onPressed: _clearTimer,
                    ),
                    const SizedBox(width: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRunning ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        fixedSize: const Size(140, 64),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: _toggleTimerEngine,
                      child: Text(_isRunning ? 'PAUSE' : 'START', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Text('Completed Sessions Today: $_completedSessionsToday', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../main.dart';

class TaskScreen extends StatefulWidget {
  final AppStateManager stateManager;
  const TaskScreen({Key? key, required this.stateManager}) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TextEditingController _taskInputController = TextEditingController();
  String _selectedCategory = 'Study';

  void _triggerTaskAdditionWorkflow() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24, left: 24, right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Queue New Execution Target', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: _taskInputController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter task criteria...',
                  hintStyle: const TextStyle(color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), minimumSize: const Size(double.infinity, 50)),
                onPressed: () {
                  if (_taskInputController.text.trim().isNotEmpty) {
                    widget.stateManager.addTask(_taskInputController.text.trim(), _selectedCategory);
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
  }

  @override
  Widget build(BuildContext context) {
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
                  const Text('Task Matrix', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  IconButton.filled(
                    backgroundColor: const Color(0xFF6366F1),
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    onPressed: _triggerTaskAdditionWorkflow,
                  )
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: widget.stateManager.tasks.isEmpty
                    ? const Center(child: Text('No elements active in workspace matrix.', style: TextStyle(color: Color(0xFF64748B))))
                    : ListView.builder(
                  itemCount: widget.stateManager.tasks.length,
                  itemBuilder: (context, index) {
                    final task = widget.stateManager.tasks[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: task.isCompleted,
                            activeColor: const Color(0xFF10B981),
                            onChanged: (_) => widget.stateManager.toggleTaskStatus(task.id),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(task.title, style: const TextStyle(color: Colors.white, fontSize: 15)),
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
import 'package:flutter/material.dart';
import '../main.dart';

class StatisticsScreen extends StatelessWidget {
  final AppStateManager stateManager;
  const StatisticsScreen({Key? key, required this.stateManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Analytics Data', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(child: _buildMetricTile('Total Metrics Logged', '${stateManager.totalFocusTime}m', const Color(0xFF6366F1))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMetricTile('Velocity Factor', '${stateManager.completedTasksCount} Completed', const Color(0xFF10B981))),
                ],
              ),
              const SizedBox(height: 32),

              const Text('WEEKLY PRODUCTIVITY VELOCITY', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
              const SizedBox(height: 16),

              Container(
                height: 180,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF334155))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildGraphBar('Mon', 25),
                    _buildGraphBar('Tue', 50),
                    _buildGraphBar('Wed', 0),
                    _buildGraphBar('Thu', 75),
                    _buildGraphBar('Fri', 40),
                    _buildGraphBar('Sat', 100),
                    _buildGraphBar('Sun', 15),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(String header, String val, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155)),
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

  Widget _buildGraphBar(String day, double structuralHeightPercentage) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            width: 14,
            decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(4)),
            alignment: Alignment.bottomCenter,
            child: Container(
              height: structuralHeightPercentage,
              width: 14,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF10B981)],
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
import 'package:flutter/material.dart';
import '../main.dart';

class SettingsScreen extends StatelessWidget {
  final AppStateManager stateManager;
  const SettingsScreen({Key? key, required this.stateManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const Text('Configuration', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            const SizedBox(height: 24),

            _buildSettingHeader('Timer Configurations'),
            ListTile(
              title: const Text('Default Focus Window', style: TextStyle(color: Colors.white)),
              subtitle: Text('${stateManager.preferences.defaultPomodoroDuration} Minutes per block', style: const TextStyle(color: Color(0xFF94A3B8))),
              trailing: const Icon(Icons.arrow_drop_down_circle_rounded, color: Color(0xFF6366F1)),
              onTap: () {
                int current = stateManager.preferences.defaultPomodoroDuration;
                int next = current == 25 ? 45 : (current == 45 ? 60 : 25);
                stateManager.updatePreferences(duration: next);
              },
            ),

            const Divider(color: Color(0xFF334155), height: 32),
            _buildSettingHeader('System Security & Alerts'),
            SwitchListTile(
              title: const Text('Execution Sound Alerts', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Trigger audio notifications on ticker depletion.', style: TextStyle(color: Color(0xFF94A3B8))),
              value: stateManager.preferences.notificationsEnabled,
              activeColor: const Color(0xFF10B981),
              onChanged: (val) => stateManager.updatePreferences(notify: val),
            ),
            SwitchListTile(
              title: const Text('Deep Work Lockout (Strict Mode)', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Prevents cancellation of running timer engines.', style: TextStyle(color: Color(0xFF94A3B8))),
              value: stateManager.preferences.strictMode,
              activeColor: const Color(0xFF10B981),
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
      child: Text(text.toUpperCase(), style: const TextStyle(color: Color(0xFF6366F1), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
    );
  }
}