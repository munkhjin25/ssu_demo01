import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const DoLineApp());
}

// ── Color Palette ──────────────────────────────────
class AppColors {
  static const bg = Color(0xFF0F0F1A);
  static const surface = Color(0xFF1A1A2E);
  static const card = Color(0xFF22223A);
  static const accent = Color(0xFF4FC3F7);
  static const accentDim = Color(0xFF1E4A6B);
  static const textPrimary = Color(0xFFE8E8F0);
  static const textSecondary = Color(0xFF8888AA);
  static const divider = Color(0xFF2A2A44);
  static const success = Color(0xFF4DB6AC);
  static const danger = Color(0xFFEF5350);
}

// ── Data Model ──────────────────────────────────────
class PledgeEntry {
  final String id;
  final String text;
  final String date;
  final bool done;

  PledgeEntry({
    required this.id,
    required this.text,
    required this.date,
    this.done = false,
  });

  PledgeEntry copyWith({bool? done, String? text}) => PledgeEntry(
    id: id,
    text: text ?? this.text,
    date: date,
    done: done ?? this.done,
  );

  Map<String, dynamic> toJson() =>
      {'id': id, 'text': text, 'date': date, 'done': done};

  factory PledgeEntry.fromJson(Map<String, dynamic> j) => PledgeEntry(
    id: j['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
    text: j['text'],
    date: j['date'],
    done: j['done'] ?? false,
  );
}

// ── App Root ──────────────────────────────────────────
class DoLineApp extends StatelessWidget {
  const DoLineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DO Line',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          surface: AppColors.surface,
        ),
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: const HomePage(),
    );
  }
}

// ── Main Screen ─────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<PledgeEntry> _entries = [];
  int _streak = 0;
  bool _todayDone = false;
  int _currentTab = 0;

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── SharedPreferences ────────────────────────────
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('entries') ?? '[]';
    final List decoded = jsonDecode(raw);
    final entries =
    decoded.map((e) => PledgeEntry.fromJson(e)).toList().cast<PledgeEntry>();
    setState(() {
      _entries = entries.reversed.toList();
      _todayDone = _entries.any((e) => e.date == _todayKey);
      _streak = _calcStreak(entries);
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final sorted = [..._entries].reversed.toList();
    await prefs.setString(
        'entries', jsonEncode(sorted.map((e) => e.toJson()).toList()));
  }

  // ── Streak Calculation ───────────────────────────
  int _calcStreak(List<PledgeEntry> entries) {
    if (entries.isEmpty) return 0;
    final doneEntries = entries.where((e) => e.done).toList();
    if (doneEntries.isEmpty) return 0;
    int streak = 0;
    DateTime check = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final key =
          '${check.year}-${check.month.toString().padLeft(2, '0')}-${check.day.toString().padLeft(2, '0')}';
      if (doneEntries.any((e) => e.date == key)) {
        streak++;
        check = check.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  // ── Add ──────────────────────────────────────────
  void _addPledge() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (_todayDone) {
      _showSnack("Today's pledge already saved ✨");
      return;
    }
    final entry = PledgeEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      date: _todayKey,
    );
    setState(() {
      _entries.insert(0, entry);
      _todayDone = true;
    });
    _controller.clear();
    _focusNode.unfocus();
    _save();
  }

  // ── Toggle Done ──────────────────────────────────
  void _toggleDone(int index) {
    setState(() {
      _entries[index] = _entries[index].copyWith(done: !_entries[index].done);
      _streak = _calcStreak(_entries.reversed.toList());
    });
    _save();
  }

  // ── Delete ───────────────────────────────────────
  void _deleteEntry(int index) {
    final wasToday = _entries[index].date == _todayKey;
    setState(() {
      _entries.removeAt(index);
      if (wasToday) _todayDone = false;
      _streak = _calcStreak(_entries.reversed.toList());
    });
    _save();
    _showSnack('Pledge deleted');
  }

  // ── Edit ─────────────────────────────────────────
  void _editEntry(int index) {
    final editController =
    TextEditingController(text: _entries[index].text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit Pledge',
            style: GoogleFonts.spaceGrotesk(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600)),
        content: TextField(
          controller: editController,
          maxLength: 50,
          autofocus: true,
          style:
          GoogleFonts.spaceGrotesk(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Edit your pledge...',
            hintStyle: GoogleFonts.spaceGrotesk(
                color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            counterStyle: GoogleFonts.spaceGrotesk(
                color: AppColors.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.spaceGrotesk(
                    color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final newText = editController.text.trim();
              if (newText.isNotEmpty) {
                setState(() {
                  _entries[index] =
                      _entries[index].copyWith(text: newText);
                });
                _save();
                Navigator.pop(ctx);
                _showSnack('Pledge updated ✓');
              }
            },
            child: Text('Save', style: GoogleFonts.spaceGrotesk()),
          ),
        ],
      ),
    ).then((_) => editController.dispose());
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style:
          GoogleFonts.spaceGrotesk(color: AppColors.textPrimary)),
      backgroundColor: AppColors.card,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  String _formatDate(String key) {
    final p = key.split('-');
    return p.length == 3 ? '${p[1]}.${p[2]}' : key;
  }

  String _weekday(String key) {
    try {
      final d = DateTime.parse(key);
      const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
      return days[d.weekday - 1];
    } catch (_) {
      return '';
    }
  }

  // ── Stats ─────────────────────────────────────────
  int get _totalEntries => _entries.length;
  int get _completedEntries => _entries.where((e) => e.done).length;
  double get _completionRate =>
      _totalEntries == 0 ? 0 : _completedEntries / _totalEntries;

  int get _bestStreak {
    if (_entries.isEmpty) return 0;
    final sorted = [..._entries.reversed];
    int best = 0, current = 0;
    DateTime? prev;
    for (final e in sorted) {
      if (!e.done) {
        current = 0;
        prev = null;
        continue;
      }
      final d = DateTime.tryParse(e.date);
      if (d == null) continue;
      if (prev == null || prev.difference(d).inDays == 1) {
        current++;
        if (current > best) best = current;
      } else {
        current = 1;
      }
      prev = d;
    }
    return best;
  }

  String _motivationMsg() {
    if (_streak == 0)
      return 'Every expert was once a beginner.\nWrite your first pledge today.';
    if (_streak < 3)
      return 'Great start! $_streak day${_streak > 1 ? 's' : ''} in.\nMomentum is building.';
    if (_streak < 7)
      return '$_streak days strong! 🔥\nYou\'re building a real habit now.';
    if (_streak < 14)
      return 'One week+ streak! 🏆\nYou\'re in the top tier of consistency.';
    return '$_streak days. That\'s extraordinary. 🌟\nOne line changed everything.';
  }

  // ── Build ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _currentTab == 0 ? _buildHome() : _buildStats(),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
              top: BorderSide(color: AppColors.divider, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTab,
          onTap: (i) => setState(() => _currentTab = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: GoogleFonts.spaceGrotesk(fontSize: 11),
          unselectedLabelStyle: GoogleFonts.spaceGrotesk(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.edit_note_rounded), label: 'Pledge'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_rounded), label: 'Stats'),
          ],
        ),
      ),
    );
  }

  // ── Home Tab ─────────────────────────────────────
  Widget _buildHome() {
    return Column(children: [
      _buildHeader(),
      _buildStreakCard(),
      _buildInputArea(),
      const SizedBox(height: 8),
      _buildListHeader(),
      Expanded(child: _buildList()),
    ]);
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    const months = [
      'JAN','FEB','MAR','APR','MAY','JUN',
      'JUL','AUG','SEP','OCT','NOV','DEC'
    ];
    final dateStr =
        '${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]} ${now.year}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('DO Line',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                  letterSpacing: -0.5)),
          Text(dateStr,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentDim, width: 1),
      ),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('🔥 Current Streak',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$_streak',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                      height: 1)),
              const SizedBox(width: 6),
              Text('days',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      color: AppColors.textSecondary)),
            ],
          ),
        ]),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('Total $_totalEntries',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(
            _todayDone ? '✓ Done today' : 'Not yet today',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _todayDone
                  ? AppColors.success
                  : AppColors.textSecondary,
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _buildInputArea() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
          _todayDone ? AppColors.divider : AppColors.accentDim,
          width: 1,
        ),
      ),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: !_todayDone,
            maxLength: 50,
            style: GoogleFonts.spaceGrotesk(
                color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: _todayDone
                  ? 'Pledge saved for today ✨'
                  : "Write today's pledge...",
              hintStyle: GoogleFonts.spaceGrotesk(
                  color: AppColors.textSecondary, fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 14),
              counterText: '',
            ),
            onSubmitted: (_) => _addPledge(),
          ),
        ),
        if (!_todayDone)
          GestureDetector(
            onTap: _addPledge,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_upward_rounded,
                  color: Colors.black, size: 18),
            ),
          ),
      ]),
    );
  }

  Widget _buildListHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(children: [
        Text('Pledge History',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.8)),
        const Spacer(),
        if (_entries.isNotEmpty)
          Text('swipe ← delete  ·  hold to edit',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 11, color: AppColors.textSecondary)),
      ]),
    );
  }

  Widget _buildList() {
    if (_entries.isEmpty) {
      return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('✏️', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 16),
              Text('Write your first pledge',
                  style: GoogleFonts.spaceGrotesk(
                      color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 6),
              Text('Deep One Line',
                  style: GoogleFonts.spaceGrotesk(
                      color: AppColors.accentDim,
                      fontSize: 12,
                      letterSpacing: 1)),
            ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        final entry = _entries[index];
        final isToday = entry.date == _todayKey;

        return Dismissible(
          key: Key(entry.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.danger.withOpacity(0.4)),
            ),
            child: const Icon(Icons.delete_outline_rounded,
                color: AppColors.danger, size: 22),
          ),
          confirmDismiss: (_) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: Text('Delete Pledge?',
                    style: GoogleFonts.spaceGrotesk(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600)),
                content: Text('"${entry.text}"',
                    style: GoogleFonts.spaceGrotesk(
                        color: AppColors.textSecondary,
                        fontSize: 13)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text('Cancel',
                        style: GoogleFonts.spaceGrotesk(
                            color: AppColors.textSecondary)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text('Delete',
                        style: GoogleFonts.spaceGrotesk(
                            color: Colors.white)),
                  ),
                ],
              ),
            ) ??
                false;
          },
          onDismissed: (_) => _deleteEntry(index),
          child: GestureDetector(
            onTap: () => _toggleDone(index),
            onLongPress: () => _editEntry(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: entry.done
                    ? AppColors.surface
                    : AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isToday
                      ? AppColors.accentDim
                      : entry.done
                      ? AppColors.success.withOpacity(0.3)
                      : AppColors.divider,
                  width: 1,
                ),
              ),
              child: Row(children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(_formatDate(entry.date),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: isToday
                              ? AppColors.accent
                              : AppColors.textSecondary,
                          fontWeight: isToday
                              ? FontWeight.w600
                              : FontWeight.w400,
                        )),
                    Text(_weekday(entry.date),
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 9,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5)),
                  ],
                ),
                const SizedBox(width: 14),
                Container(
                    width: 1,
                    height: 30,
                    color: AppColors.divider),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(entry.text,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: entry.done
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        decoration: entry.done
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: AppColors.textSecondary,
                      )),
                ),
                const SizedBox(width: 8),
                Icon(
                  entry.done
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: entry.done
                      ? AppColors.success
                      : AppColors.divider,
                  size: 20,
                ),
              ]),
            ),
          ),
        );
      },
    );
  }

  // ── Stats Tab ─────────────────────────────────────
  Widget _buildStats() {
    final rate = (_completionRate * 100).toStringAsFixed(0);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Stats',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                  letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text('Your pledge journey so far',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 24),

          Row(children: [
            _statCard('🔥', 'Current\nStreak', '$_streak days',
                AppColors.accent),
            const SizedBox(width: 12),
            _statCard('🏆', 'Best\nStreak', '$_bestStreak days',
                AppColors.success),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _statCard('📝', 'Total\nPledges', '$_totalEntries',
                const Color(0xFFCE93D8)),
            const SizedBox(width: 12),
            _statCard('✅', 'Completed', '$_completedEntries',
                const Color(0xFFFFCC80)),
          ]),
          const SizedBox(height: 24),

          // Completion rate bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Completion Rate',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                Row(children: [
                  Text('$rate%',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const Spacer(),
                  Text('$_completedEntries / $_totalEntries',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          color: AppColors.textSecondary)),
                ]),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _completionRate,
                    minHeight: 10,
                    backgroundColor: AppColors.divider,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.accent),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Last 7 days
          Text('Last 7 Days',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          _buildWeekView(),
          const SizedBox(height: 24),

          // Motivation message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.accentDim.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accentDim),
            ),
            child: Column(children: [
              Text(_motivationMsg(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      height: 1.6)),
              const SizedBox(height: 6),
              Text('— DO Line',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 11, color: AppColors.accent)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
      String emoji, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 8),
              Text(label,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.4)),
              const SizedBox(height: 4),
              Text(value,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ]),
      ),
    );
  }

  Widget _buildWeekView() {
    final now = DateTime.now();
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = now.subtract(Duration(days: 6 - i));
        final key =
            '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
        final entry =
            _entries.where((e) => e.date == key).firstOrNull;
        final isDone = entry?.done ?? false;
        final hasPledge = entry != null;
        final isToday = key == _todayKey;

        return Column(children: [
          Text(dayLabels[day.weekday - 1],
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDone
                  ? AppColors.success
                  : hasPledge
                  ? AppColors.accentDim
                  : AppColors.card,
              borderRadius: BorderRadius.circular(10),
              border: isToday
                  ? Border.all(color: AppColors.accent, width: 2)
                  : null,
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check_rounded,
                  color: Colors.white, size: 16)
                  : hasPledge
                  ? const Icon(Icons.remove_rounded,
                  color: AppColors.accent, size: 14)
                  : Text(day.day.toString(),
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: AppColors.textSecondary)),
            ),
          ),
        ]);
      }),
    );
  }
}