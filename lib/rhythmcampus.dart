import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

void main() {
  runApp(const RhythmCampusApp());
}

// ═══════════════════════════════
//  데이터 모델
// ═══════════════════════════════
class Habit {
  final int id;
  String name;
  String icon;
  String time;
  bool isDone;
  int completedDays;
  final int totalDays;

  Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.time,
    this.isDone = false,
    this.completedDays = 0,
    this.totalDays = 20,
  });

  String get rateLabel =>
      totalDays == 0 ? '0%' : '${(completedDays / totalDays * 100).round()}%';
}

// 전체 습관 목록
final List<Habit> _habits = [
  Habit(id:1, name:'아침 조깅 30분',    icon:'🏃', time:'07:00', isDone:true,  completedDays:17),
  Habit(id:2, name:'영어 기사 읽기',     icon:'📖', time:'08:30', isDone:true,  completedDays:18),
  Habit(id:3, name:'단어 20개 외우기',    icon:'📝', time:'10:00', isDone:true,  completedDays:14),
  Habit(id:4, name:'포모도로 집중 학습',   icon:'🍅', time:'14:00', isDone:false, completedDays:13),
  Habit(id:5, name:'취침 전 명상 10분', icon:'🧘', time:'22:30', isDone:false, completedDays:11),
];

// ═══════════════════════════════
//  앱 진입점
// ═══════════════════════════════
class RhythmCampusApp extends StatelessWidget {
  const RhythmCampusApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rhythm Campus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF82)),
        useMaterial3: true,
      ),
      home: const MainScaffold(),
    );
  }
}

// ═══════════════════════════════
//  메인 프레임 (하단 네비게이션)
// ═══════════════════════════════
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onUpdate: () => setState(() {})),
      HabitPage(onUpdate: () => setState(() {})),
      const PomodoroPage(),
      const StatsPage(),
      const FriendsPage(),
      const ProfilePage(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined),     selectedIcon: Icon(Icons.home),         label:'홈'),
          NavigationDestination(icon: Icon(Icons.checklist_outlined), selectedIcon: Icon(Icons.checklist),   label:'습관'),
          NavigationDestination(icon: Icon(Icons.timer_outlined),     selectedIcon: Icon(Icons.timer),        label:'포모도로'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart),   label:'통계'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events), label:'랭킹'),
          NavigationDestination(icon: Icon(Icons.person_outline),     selectedIcon: Icon(Icons.person),      label:'내 정보'),
        ],
      ),
    );
  }
}

// ═══════════════════════════════
//  홈 페이지
// ═══════════════════════════════
class HomePage extends StatefulWidget {
  final VoidCallback onUpdate;
  const HomePage({super.key, required this.onUpdate});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int get _done  => _habits.where((h) => h.isDone).length;
  int get _total => _habits.length;

  // 폭죽 애니메이션 컨트롤러
  late AnimationController _confettiCtrl;
  bool _showConfetti = false;
  bool _wasComplete = false;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    super.dispose();
  }

  void _toggle(Habit h) {
    setState(() {
      h.isDone = !h.isDone;
      h.completedDays = (h.completedDays + (h.isDone ? 1 : -1)).clamp(0, 999);
    });
    // 모든 습관 완료 시 폭죽 효과
    if (_done == _total && !_wasComplete) {
      _wasComplete = true;
      setState(() => _showConfetti = true);
      _confettiCtrl.forward(from: 0).then((_) {
        if (mounted) setState(() => _showConfetti = false);
      });
    } else if (_done < _total) {
      _wasComplete = false;
    }
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekdays = ['월','화','수','목','금','토','일'];
    final cs = Theme.of(context).colorScheme;
    final progress = _total == 0 ? 0.0 : _done / _total;

    return Scaffold(
      body: Stack(children: [
        SafeArea(child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20,20,20,0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('안녕하세요 👋', style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
                Text('${now.month}월 ${now.day}일 ${weekdays[now.weekday-1]}',
                    style: TextStyle(color: cs.onSurfaceVariant)),
              ]),
              // 🌱 식물 성장 위젯
              PlantWidget(progress: progress),
            ]),
          )),
          SliverToBoxAdapter(child: Container(
            margin: const EdgeInsets.fromLTRB(20,20,20,0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF82), Color(0xFF2E9E6B)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('오늘 완료', style: TextStyle(color: Colors.white70)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal:10, vertical:4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('연속 체크인 🔥',
                      style: TextStyle(color:Colors.white, fontSize:12, fontWeight:FontWeight.w600)),
                ),
              ]),
              const SizedBox(height:8),
              Text('$_done / $_total', style: const TextStyle(
                  color:Colors.white, fontSize:40, fontWeight:FontWeight.w800)),
              const SizedBox(height:12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height:8),
              Text(
                _done==_total ? '🎉 오늘 목표 달성！' : '${_total-_done}개 남았어요',
                style: const TextStyle(color:Colors.white70, fontSize:13),
              ),
            ]),
          )),
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20,24,20,12),
            child: Text('오늘의 습관', style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
          )),
          SliverList(delegate: SliverChildBuilderDelegate(
                (context, i) => _HabitTile(habit: _habits[i], onToggle: _toggle),
            childCount: _habits.length,
          )),
          const SliverToBoxAdapter(child: SizedBox(height:24)),
        ])),
        // 폭죽 오버레이
        if (_showConfetti)
          IgnorePointer(
            child: ConfettiOverlay(animation: _confettiCtrl),
          ),
      ]),
    );
  }
}

// ═══════════════════════════════
//  습관 목록 페이지 (2주차 ✅)
// ═══════════════════════════════
class HabitPage extends StatefulWidget {
  final VoidCallback onUpdate;
  const HabitPage({super.key, required this.onUpdate});
  @override
  State<HabitPage> createState() => _HabitPageState();
}

class _HabitPageState extends State<HabitPage> {
  void _toggle(Habit h) {
    setState(() {
      h.isDone = !h.isDone;
      h.completedDays = (h.completedDays + (h.isDone ? 1 : -1)).clamp(0, 999);
    });
    widget.onUpdate();
  }

  void _deleteHabit(Habit h) {
    setState(() => _habits.remove(h));
    widget.onUpdate();
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    String selectedIcon = '⭐';
    final icons = ['⭐','🏃','📖','📝','🍅','🧘','💪','🎵','🎨','💧','🥗','😴'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: const Text('습관 추가'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: '습관 이름',
                border: OutlineInputBorder(),
                hintText: '예: 매일 물 8잔 마시기',
              ),
            ),
            const SizedBox(height:16),
            const Align(alignment: Alignment.centerLeft,
                child: Text('아이콘 선택', style: TextStyle(fontWeight: FontWeight.w500))),
            const SizedBox(height:8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: icons.map((ic) => GestureDetector(
                onTap: () => setDlg(() => selectedIcon = ic),
                child: Container(
                  width:44, height:44,
                  decoration: BoxDecoration(
                    color: selectedIcon == ic
                        ? const Color(0xFF4CAF82).withOpacity(0.2)
                        : Colors.transparent,
                    border: Border.all(
                      color: selectedIcon == ic
                          ? const Color(0xFF4CAF82)
                          : Colors.grey.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text(ic, style: const TextStyle(fontSize:22))),
                ),
              )).toList(),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
            FilledButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                setState(() {
                  _habits.add(Habit(
                    id: DateTime.now().millisecondsSinceEpoch,
                    name: name,
                    icon: selectedIcon,
                    time: '08:00',
                    totalDays: 1,
                  ));
                });
                widget.onUpdate();
                Navigator.pop(ctx);
              },
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final done  = _habits.where((h) => h.isDone).length;
    final total = _habits.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('습관 목록'),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right:16),
            child: Center(child: Text('$done / $total 완료됨',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize:14))),
          ),
        ],
      ),
      body: _habits.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('📋', style: TextStyle(fontSize:56)),
        const SizedBox(height:12),
        Text('아직 습관이 없어요. + 버튼으로 추가해보세요',
            style: TextStyle(color: cs.onSurfaceVariant)),
      ]))
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(16,8,16,80),
        itemCount: _habits.length,
        itemBuilder: (ctx, i) {
          final h = _habits[i];
          return Dismissible(
            key: Key(h.id.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              margin: const EdgeInsets.only(bottom:10),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right:20),
              child: const Icon(Icons.delete_outline, color:Colors.white, size:28),
            ),
            onDismissed: (_) => _deleteHabit(h),
            child: Container(
              margin: const EdgeInsets.only(bottom:10),
              padding: const EdgeInsets.symmetric(horizontal:16, vertical:14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: h.isDone
                      ? const Color(0xFF4CAF82).withOpacity(0.4)
                      : cs.outlineVariant.withOpacity(0.3),
                ),
              ),
              child: Row(children: [
                GestureDetector(
                  onTap: () => _toggle(h),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds:200),
                    width:28, height:28,
                    decoration: BoxDecoration(
                      color: h.isDone ? const Color(0xFF4CAF82) : Colors.transparent,
                      border: Border.all(
                        color: h.isDone ? const Color(0xFF4CAF82) : cs.outline,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: h.isDone
                        ? const Icon(Icons.check, color:Colors.white, size:18)
                        : null,
                  ),
                ),
                const SizedBox(width:14),
                Text(h.icon, style: const TextStyle(fontSize:22)),
                const SizedBox(width:10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.name, style: TextStyle(
                      fontWeight: FontWeight.w500, fontSize:15,
                      decoration: h.isDone ? TextDecoration.lineThrough : null,
                      color: h.isDone ? cs.onSurfaceVariant : cs.onSurface,
                    )),
                    Row(children: [
                      Icon(Icons.access_time, size:12, color:cs.onSurfaceVariant),
                      const SizedBox(width:4),
                      Text(h.time, style: TextStyle(fontSize:12, color:cs.onSurfaceVariant)),
                    ]),
                  ],
                )),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal:8, vertical:3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF82).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(h.rateLabel, style: const TextStyle(
                      color:Color(0xFF2E9E6B), fontSize:12, fontWeight:FontWeight.w600)),
                ),
              ]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF4CAF82),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('습관 추가'),
      ),
    );
  }
}

// ═══════════════════════════════
//  포모도로 페이지 (2주차 ✅)
// ═══════════════════════════════
class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});
  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  // 모드: 집중 / 짧은 휴식 / 긴 휴식
  static const _modes = ['집중', '짧은 휴식', '긴 휴식'];
  static const _durations = [25 * 60, 5 * 60, 15 * 60]; // 초
  static const _colors = [Color(0xFF4CAF82), Color(0xFF2196F3), Color(0xFF9C27B0)];

  int _modeIndex = 0;
  late int _secondsLeft;
  bool _running = false;
  int _completedPomodoros = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = _durations[_modeIndex];
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _switchMode(int i) {
    _timer?.cancel();
    setState(() {
      _modeIndex = i;
      _secondsLeft = _durations[i];
      _running = false;
    });
  }

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
    } else {
      setState(() => _running = true);
      _timer = Timer.periodic(const Duration(seconds:1), (_) {
        if (_secondsLeft > 0) {
          setState(() => _secondsLeft--);
        } else {
          _timer?.cancel();
          setState(() {
            _running = false;
            if (_modeIndex == 0) _completedPomodoros++;
          });
          _showFinishDialog();
        }
      });
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = _durations[_modeIndex];
      _running = false;
    });
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_modeIndex == 0 ? '🎉 집중 완료！' : '✅ 휴식 종료'),
        content: Text(_modeIndex == 0
            ? '완료！ 포모도로 $_completedPomodoros 개를 마쳤어요. 잠깐 쉬세요.'
            : '휴식 종료！ 다시 집중할 준비가 됐나요？'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _switchMode(_modeIndex == 0 ? 1 : 0);
            },
            child: Text(_modeIndex == 0 ? '휴식 시작' : '집중 시작'),
          ),
        ],
      ),
    );
  }

  String get _timeLabel {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }

  double get _progress =>
      1 - _secondsLeft / _durations[_modeIndex];

  @override
  Widget build(BuildContext context) {
    final color = _colors[_modeIndex];
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('포모도로'), centerTitle: false),
      body: SafeArea(child: Column(children: [
        // 모드 전환
        Padding(
          padding: const EdgeInsets.fromLTRB(20,16,20,0),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: List.generate(3, (i) => Expanded(
              child: GestureDetector(
                onTap: () => _switchMode(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds:200),
                  padding: const EdgeInsets.symmetric(vertical:10),
                  decoration: BoxDecoration(
                    color: _modeIndex == i ? _colors[i] : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_modes[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: _modeIndex == i ? Colors.white : cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ))),
          ),
        ),

        // 타이머 원형
        Expanded(child: Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 220, height: 220,
              child: Stack(alignment: Alignment.center, children: [
                SizedBox(
                  width: 220, height: 220,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 10,
                    backgroundColor: color.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(_timeLabel, style: TextStyle(
                      fontSize: 52, fontWeight: FontWeight.w700, color: color)),
                  Text(_modes[_modeIndex], style: TextStyle(
                      fontSize: 16, color: cs.onSurfaceVariant)),
                ]),
              ]),
            ),
            const SizedBox(height: 40),

            // 컨트롤 버튼
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              // 초기화
              IconButton(
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
                iconSize: 32,
                color: cs.onSurfaceVariant,
              ),
              const SizedBox(width: 24),
              // 시작/일시정지
              GestureDetector(
                onTap: _toggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds:200),
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 16, offset: const Offset(0,6),
                    )],
                  ),
                  child: Icon(
                    _running ? Icons.pause : Icons.play_arrow,
                    color: Colors.white, size: 40,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // 건너뛰기
              IconButton(
                onPressed: () => _switchMode((_modeIndex + 1) % 3),
                icon: const Icon(Icons.skip_next),
                iconSize: 32,
                color: cs.onSurfaceVariant,
              ),
            ]),
          ],
        ))),

        // 하단 포모도로 카운트
        Padding(
          padding: const EdgeInsets.fromLTRB(20,0,20,24),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('오늘 집중', style: TextStyle(
                    color: cs.onSurfaceVariant, fontSize:14)),
                Row(children: [
                  ...List.generate(
                    _completedPomodoros.clamp(0,8),
                        (_) => const Padding(
                      padding: EdgeInsets.only(right:4),
                      child: Text('🍅', style: TextStyle(fontSize:18)),
                    ),
                  ),
                  if (_completedPomodoros == 0)
                    Text('완료된 포모도로 없음',
                        style: TextStyle(color: cs.onSurfaceVariant, fontSize:13)),
                ]),
              ],
            ),
          ),
        ),
      ])),
    );
  }
}

// ═══════════════════════════════
//  공통 위젯
// ═══════════════════════════════
class _HabitTile extends StatelessWidget {
  final Habit habit;
  final void Function(Habit) onToggle;
  const _HabitTile({required this.habit, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final h = habit;
    return Container(
      margin: const EdgeInsets.fromLTRB(20,0,20,10),
      padding: const EdgeInsets.symmetric(horizontal:16, vertical:14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: h.isDone
              ? const Color(0xFF4CAF82).withOpacity(0.4)
              : cs.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () => onToggle(h),
          child: AnimatedContainer(
            duration: const Duration(milliseconds:200),
            width:28, height:28,
            decoration: BoxDecoration(
              color: h.isDone ? const Color(0xFF4CAF82) : Colors.transparent,
              border: Border.all(
                  color: h.isDone ? const Color(0xFF4CAF82) : cs.outline, width:2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: h.isDone
                ? const Icon(Icons.check, color:Colors.white, size:18)
                : null,
          ),
        ),
        const SizedBox(width:14),
        Text(h.icon, style: const TextStyle(fontSize:20)),
        const SizedBox(width:10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(h.name, style: TextStyle(
            fontWeight: FontWeight.w500, fontSize:15,
            decoration: h.isDone ? TextDecoration.lineThrough : null,
            color: h.isDone ? cs.onSurfaceVariant : cs.onSurface,
          )),
          Text(h.time, style: TextStyle(fontSize:12, color:cs.onSurfaceVariant)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal:8, vertical:3),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF82).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(h.rateLabel, style: const TextStyle(
              color:Color(0xFF2E9E6B), fontSize:12, fontWeight:FontWeight.w600)),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════
//  통계 페이지 (3주차 ✅)
// ═══════════════════════════════

// 최근 7일 체크인 데이터 (샘플)
final List<Map<String, dynamic>> _weekData = [
  {'day': '월', 'rate': 0.6},
  {'day': '화', 'rate': 0.8},
  {'day': '수', 'rate': 1.0},
  {'day': '목', 'rate': 0.4},
  {'day': '금', 'rate': 0.8},
  {'day': '토', 'rate': 0.6},
  {'day': '일', 'rate': 0.8},
];

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});
  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int _selectedTab = 0; // 0=이번주, 1=이번달

  // 월간 데이터 (30일 샘플)
  final List<double> _monthRates = [
    0.8,1.0,0.6,0.4,1.0,0.8,0.6,
    1.0,0.8,1.0,0.6,0.8,1.0,0.4,
    0.8,0.6,1.0,0.8,0.6,1.0,0.8,
    0.6,0.4,1.0,0.8,0.6,1.0,0.8,
    0.6,0.8,
  ];

  double get _avgRate {
    final data = _selectedTab == 0
        ? _weekData.map((d) => d['rate'] as double).toList()
        : _monthRates;
    return data.reduce((a, b) => a + b) / data.length;
  }

  int get _totalDone => _habits.fold(0, (sum, h) => sum + h.completedDays);
  int get _perfectDays => (_selectedTab == 0 ? _weekData.map((d) => d['rate'] as double).toList() : _monthRates)
      .where((r) => r >= 1.0).length;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('통계'), centerTitle: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── 주/월 전환 ──
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              _TabBtn(label: '이번 주', selected: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0)),
              _TabBtn(label: '이번 달', selected: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1)),
            ]),
          ),
          const SizedBox(height: 16),

          // ── 개요 카드 3개 ──
          Row(children: [
            _StatCard(
              icon: '🎯', label: '평균 완료율',
              value: '${(_avgRate * 100).round()}%',
              color: const Color(0xFF4CAF82),
            ),
            const SizedBox(width: 10),
            _StatCard(
              icon: '🔥', label: '개근 일수',
              value: '$_perfectDays일',
              color: const Color(0xFFFF7043),
            ),
            const SizedBox(width: 10),
            _StatCard(
              icon: '✅', label: '누적 체크인',
              value: '$_totalDone 회',
              color: const Color(0xFF2196F3),
            ),
          ]),
          const SizedBox(height: 20),

          // ── 체크인율 바 차트 ──
          _SectionTitle(title: _selectedTab == 0 ? '이번 주 체크인율' : '이번 달 체크인율'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _selectedTab == 0
                ? _WeekBarChart(data: _weekData)
                : _MonthHeatmap(rates: _monthRates),
          ),
          const SizedBox(height: 20),

          // ── 습관별 완료 현황 ──
          const _SectionTitle(title: '습관별 완료 현황'),
          const SizedBox(height: 12),
          ..._habits.map((h) => _HabitStatRow(habit: h)),
          const SizedBox(height: 20),

          // ── 성취 뱃지 ──
          const _SectionTitle(title: '성취 뱃지'),
          const SizedBox(height: 12),
          _AchievementGrid(completedTotal: _totalDone, avgRate: _avgRate),
          const SizedBox(height: 24),

          // ── 🤖 AI 개인화 조언 ──
          const _SectionTitle(title: '🤖 AI 개인화 조언'),
          const SizedBox(height: 12),
          _AiAdviceCard(
            avgRate: _avgRate,
            totalDone: _totalDone,
            perfectDays: _perfectDays,
            habits: _habits,
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

// 주간 바 차트
class _WeekBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _WeekBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxH = 120.0;
    return SizedBox(
      height: maxH + 28,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: data.map((d) {
          final rate = d['rate'] as double;
          final barH = rate * maxH;
          final color = rate >= 1.0
              ? const Color(0xFF4CAF82)
              : rate >= 0.6
              ? const Color(0xFF81C784)
              : const Color(0xFFFFCC80);
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('${(rate * 100).round()}%',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                width: 32, height: barH,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              Text(d['day'] as String,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// 월간 히트맵
class _MonthHeatmap extends StatelessWidget {
  final List<double> rates;
  const _MonthHeatmap({required this.rates});

  Color _color(double r) {
    if (r >= 1.0) return const Color(0xFF2E7D32);
    if (r >= 0.8) return const Color(0xFF4CAF82);
    if (r >= 0.6) return const Color(0xFF81C784);
    if (r >= 0.4) return const Color(0xFFC8E6C9);
    return const Color(0xFFEEEEEE);
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(
        spacing: 6, runSpacing: 6,
        children: List.generate(rates.length, (i) => Tooltip(
          message: '${i+1}일 ${(rates[i]*100).round()}%',
          child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: _color(rates[i]),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text('${i+1}',
                  style: const TextStyle(fontSize: 9, color: Colors.white70)),
            ),
          ),
        )),
      ),
      const SizedBox(height: 12),
      Row(children: [
        const Text('적음', style: TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(width: 6),
        ...[0.2, 0.5, 0.7, 0.9, 1.0].map((r) => Container(
          width: 16, height: 16,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(color: _color(r), borderRadius: BorderRadius.circular(3)),
        )),
        const Text('많음', style: TextStyle(fontSize: 11, color: Colors.grey)),
      ]),
    ]);
  }
}

// 습관 진행 행
class _HabitStatRow extends StatelessWidget {
  final Habit habit;
  const _HabitStatRow({required this.habit});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final rate = habit.totalDays == 0 ? 0.0 : habit.completedDays / habit.totalDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        Text(habit.icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(habit.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            Text(habit.rateLabel,
                style: const TextStyle(color: Color(0xFF4CAF82), fontWeight: FontWeight.w700, fontSize: 14)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rate,
              minHeight: 6,
              backgroundColor: cs.outlineVariant.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                rate >= 0.8 ? const Color(0xFF4CAF82) : const Color(0xFFFFB74D),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text('${habit.completedDays} / ${habit.totalDays}일',
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
        ])),
      ]),
    );
  }
}

// 성취 뱃지
class _AchievementGrid extends StatelessWidget {
  final int completedTotal;
  final double avgRate;
  const _AchievementGrid({required this.completedTotal, required this.avgRate});

  @override
  Widget build(BuildContext context) {
    final badges = [
      {'icon':'🌱', 'name':'새싹',  'desc':'첫 체크인 완료',     'unlocked': completedTotal >= 1},
      {'icon':'🌿', 'name':'꾸준한 성장',  'desc':'누적 체크인 10회',   'unlocked': completedTotal >= 10},
      {'icon':'🌳', 'name':'무성한 나무',  'desc':'누적 체크인 50회',   'unlocked': completedTotal >= 50},
      {'icon':'🔥', 'name':'불꽃 집중',  'desc':'평균 완료율 ≥ 80%', 'unlocked': avgRate >= 0.8},
      {'icon':'💎', 'name':'완벽주의',  'desc':'하루 전부 완료',     'unlocked': true},
      {'icon':'🏆', 'name':'자율 챔피언',  'desc':'7일 연속 체크인',    'unlocked': completedTotal >= 35},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.95,
      children: badges.map((b) {
        final unlocked = b['unlocked'] as bool;
        return Container(
          decoration: BoxDecoration(
            color: unlocked
                ? const Color(0xFF4CAF82).withOpacity(0.1)
                : Colors.grey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: unlocked
                  ? const Color(0xFF4CAF82).withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
            ),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(b['icon'] as String,
                style: TextStyle(fontSize: 28,
                    color: unlocked ? null : const Color(0xFFBDBDBD))),
            const SizedBox(height: 6),
            Text(b['name'] as String,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: unlocked ? const Color(0xFF2E7D32) : Colors.grey)),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(b['desc'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ),
            if (!unlocked) ...[
              const SizedBox(height: 4),
              const Icon(Icons.lock_outline, size: 14, color: Colors.grey),
            ]
          ]),
        );
      }).toList(),
    );
  }
}

// ─── AI 개인화 조언 카드 ───────────────
class _AiAdviceCard extends StatefulWidget {
  final double avgRate;
  final int totalDone;
  final int perfectDays;
  final List<Habit> habits;

  const _AiAdviceCard({
    required this.avgRate,
    required this.totalDone,
    required this.perfectDays,
    required this.habits,
  });

  @override
  State<_AiAdviceCard> createState() => _AiAdviceCardState();
}

class _AiAdviceCardState extends State<_AiAdviceCard> {
  String _advice = '';
  bool _loading = false;
  bool _hasLoaded = false;
  String _error = '';

  String _buildPrompt() {
    final habitLines = widget.habits.map((h) =>
    '- ${h.icon} ${h.name}: ${h.completedDays}/${h.totalDays}일 완료 (${h.rateLabel})'
    ).join('\n');

    return '''
당신은 대학생 습관 관리 앱 "Rhythm Campus"의 AI 코치입니다.
아래 사용자 데이터를 분석하고, 한국어로 친근하고 구체적인 조언을 해주세요.

[사용자 데이터]
- 평균 완료율: ${(widget.avgRate * 100).round()}%
- 누적 체크인: ${widget.totalDone}회
- 개근 일수: ${widget.perfectDays}일
- 습관 목록:
$habitLines

[요청]
1. 잘하고 있는 점 1가지 (칭찬)
2. 가장 개선이 필요한 습관 1가지와 구체적인 실천 팁
3. 이번 주 도전 목표 1가지

이모지를 활용해서 읽기 쉽게 작성해주세요. 총 150자 이내로 간결하게.
''';
  }

  Future<void> _fetchAdvice() async {
    setState(() {
      _loading = true;
      _error = '';
      _advice = '';
    });

    try {
      final response = await _callClaudeApi(_buildPrompt());
      if (mounted) {
        setState(() {
          _advice = response;
          _loading = false;
          _hasLoaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '조언을 불러오지 못했어요. 다시 시도해 주세요.';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CAF82).withOpacity(0.08),
            const Color(0xFF2196F3).withOpacity(0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4CAF82).withOpacity(0.25),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 헤더
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF82).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('🤖', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('AI 코치', style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15)),
              Text('내 데이터 기반 맞춤 조언', style: TextStyle(
                  fontSize: 12, color: cs.onSurfaceVariant)),
            ],
          )),
          if (_hasLoaded)
            IconButton(
              onPressed: _loading ? null : _fetchAdvice,
              icon: const Icon(Icons.refresh, size: 18),
              tooltip: '다시 분석',
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF82).withOpacity(0.1),
              ),
            ),
        ]),
        const SizedBox(height: 14),

        // 내용 영역
        if (!_hasLoaded && !_loading && _error.isEmpty)
          _buildInitialState()
        else if (_loading)
          _buildLoadingState()
        else if (_error.isNotEmpty)
            _buildErrorState()
          else
            _buildAdviceContent(),
      ]),
    );
  }

  Widget _buildInitialState() {
    return Column(children: [
      // 데이터 미리보기
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          _DataRow(icon: '🎯', label: '평균 완료율',
              value: '${(widget.avgRate * 100).round()}%'),
          const Divider(height: 12, thickness: 0.5),
          _DataRow(icon: '✅', label: '누적 체크인',
              value: '${widget.totalDone}회'),
          const Divider(height: 12, thickness: 0.5),
          _DataRow(icon: '🔥', label: '개근 일수',
              value: '${widget.perfectDays}일'),
        ]),
      ),
      const SizedBox(height: 14),
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _fetchAdvice,
          icon: const Text('✨', style: TextStyle(fontSize: 16)),
          label: const Text('AI 분석 시작'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF82),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    ]);
  }

  Widget _buildLoadingState() {
    return Column(children: [
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          width: 20, height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: const Color(0xFF4CAF82),
          ),
        ),
        const SizedBox(width: 12),
        Text('데이터 분석 중...', style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14)),
      ]),
      const SizedBox(height: 16),
      // 스켈레톤 UI
      ...List.generate(3, (i) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        height: 14,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.15),
          borderRadius: BorderRadius.circular(7),
        ),
      )),
    ]);
  }

  Widget _buildErrorState() {
    return Column(children: [
      const Text('⚠️', style: TextStyle(fontSize: 32)),
      const SizedBox(height: 8),
      Text(_error, textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 13)),
      const SizedBox(height: 12),
      TextButton.icon(
        onPressed: _fetchAdvice,
        icon: const Icon(Icons.refresh, size: 16),
        label: const Text('다시 시도'),
        style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF4CAF82)),
      ),
    ]);
  }

  Widget _buildAdviceContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _advice,
        style: const TextStyle(fontSize: 14, height: 1.7),
      ),
    );
  }
}

// 데이터 행 위젯
class _DataRow extends StatelessWidget {
  final String icon, label, value;
  const _DataRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(icon, style: const TextStyle(fontSize: 14)),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(
          fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      const Spacer(),
      Text(value, style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w700,
          color: Color(0xFF2E9E6B))),
    ]);
  }
}

// ─── 로컬 AI 분석 함수 ───────────────
Future<String> _callClaudeApi(String prompt) async {
  // 실제 습관 데이터 기반 로컬 분석
  await Future.delayed(const Duration(milliseconds: 1200)); // 분석 중 느낌

  final done = _habits.where((h) => h.isDone).length;
  final total = _habits.length;
  final rate = total == 0 ? 0.0 : done / total;

  // 완료율 낮은 습관 찾기
  final sorted = List<Habit>.from(_habits)
    ..sort((a, b) => a.completedDays.compareTo(b.completedDays));
  final weakest = sorted.first;

  // 완료율 높은 습관 찾기
  final strongest = sorted.last;

  // 칭찬 메시지
  String praise;
  if (rate >= 0.8) {
    praise = '✅ 오늘 완료율 ${(rate*100).round()}%！정말 대단해요, 꾸준함이 빛나고 있어요！';
  } else if (rate >= 0.5) {
    praise = '✅ ${strongest.icon} "${strongest.name}" 습관이 ${strongest.rateLabel} 달성！꾸준히 잘 하고 있어요。';
  } else {
    praise = '✅ 오늘 힘든 하루였겠지만, 시작한 것만으로도 충분히 잘하고 있어요！';
  }

  // 개선 팁
  final tip = '📌 "${weakest.icon} ${weakest.name}" 완료율이 ${weakest.rateLabel}로 가장 낮아요。'
      '${_getTip(weakest.name)}';

  // 이번 주 목표
  final goal = _getWeeklyGoal(rate);

  return '$praise\n\n$tip\n\n$goal';
}

String _getTip(String habitName) {
  if (habitName.contains('조깅') || habitName.contains('운동')) {
    return ' 아침 알람을 10분 일찍 맞추고 운동복을 미리 꺼내두면 실천이 쉬워져요！';
  } else if (habitName.contains('영어') || habitName.contains('읽기')) {
    return ' 하루 1페이지부터 시작해보세요。부담을 줄이면 지속하기 훨씬 쉬워요！';
  } else if (habitName.contains('단어') || habitName.contains('외우')) {
    return ' 자기 전 5분, 아침 기상 후 5분으로 나눠서 외우면 기억에 더 오래 남아요！';
  } else if (habitName.contains('포모도로') || habitName.contains('집중')) {
    return ' 핸드폰을 다른 방에 두고 시작하면 집중력이 확 올라가요！';
  } else if (habitName.contains('명상') || habitName.contains('휴식')) {
    return ' 취침 30분 전 조명을 어둡게 하고 시작하면 명상이 훨씬 잘 돼요！';
  } else {
    return ' 매일 같은 시간에 실천하면 습관으로 자리잡기 훨씬 쉬워요！';
  }
}

String _getWeeklyGoal(double rate) {
  if (rate >= 0.8) {
    return '🎯 이번 주 목표: 7일 연속 완료율 80% 이상 유지하고 🏆 자율 챔피언 뱃지 획득！';
  } else if (rate >= 0.5) {
    return '🎯 이번 주 목표: 매일 최소 3개 습관 완료하기。작은 성공이 쌓이면 큰 변화가 돼요！';
  } else {
    return '🎯 이번 주 목표: 하루 1개 습관이라도 꼭 완료하기。오늘 한 걸음이 내일의 나를 만들어요！';
  }
}


class _TabBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF4CAF82) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: selected ? Colors.white
                      : Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.w600));
  }
}

class _StatCard extends StatelessWidget {
  final String icon, label, value;
  final Color color;
  const _StatCard({required this.icon, required this.label,
    required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════
//  마이 페이지
// ═══════════════════════════════
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = '학생';
  String _avatar = '🧑‍💻';
  bool _notifyEnabled = true;
  bool _darkMode = false;
  int _pomoDuration = 25;

  final _avatarOptions = ['🧑‍💻','👩‍🎓','🧑‍🎓','👨‍💻','🧑','👩','🐱','🐶','🦊','🐼'];

  void _editName() {
    final ctrl = TextEditingController(text: _name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('닉네임 수정'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 10,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: '닉네임을 입력하세요',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          FilledButton(
            onPressed: () {
              final v = ctrl.text.trim();
              if (v.isNotEmpty) setState(() => _name = v);
              Navigator.pop(ctx);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _editAvatar() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('아바타 선택'),
        content: Wrap(
          spacing: 10, runSpacing: 10,
          children: _avatarOptions.map((a) => GestureDetector(
            onTap: () {
              setState(() => _avatar = a);
              Navigator.pop(ctx);
            },
            child: Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: a == _avatar
                    ? const Color(0xFF4CAF82).withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: a == _avatar
                      ? const Color(0xFF4CAF82)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(child: Text(a, style: const TextStyle(fontSize: 26))),
            ),
          )).toList(),
        ),
      ),
    );
  }

  void _editPomoDuration() {
    int temp = _pomoDuration;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: const Text('집중 시간'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('$temp 분',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700,
                    color: Color(0xFF4CAF82))),
            const SizedBox(height: 16),
            Slider(
              value: temp.toDouble(),
              min: 10, max: 60, divisions: 10,
              activeColor: const Color(0xFF4CAF82),
              label: '$temp 분',
              onChanged: (v) => setDlg(() => temp = v.round()),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
              Text('10분', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text('60분', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
            FilledButton(
              onPressed: () {
                setState(() => _pomoDuration = temp);
                Navigator.pop(ctx);
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetConfirm() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ 데이터 삭제'),
        content: const Text('모든 습관과 체크인 기록이 삭제됩니다. 되돌릴 수 없습니다. 계속하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          TextButton(
            onPressed: () {
              setState(() {
                _habits.clear();
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('데이터가 삭제되었습니다'), backgroundColor: Colors.red),
              );
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalDone = _habits.fold(0, (s, h) => s + h.completedDays);
    final avgRate = _habits.isEmpty ? 0.0
        : _habits.map((h) => h.completedDays / h.totalDays)
        .reduce((a, b) => a + b) / _habits.length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [

            // ── 상단 아바타 카드 ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4CAF82), Color(0xFF2E9E6B)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
              ),
              child: Column(children: [
                GestureDetector(
                  onTap: _editAvatar,
                  child: Stack(alignment: Alignment.bottomRight, children: [
                    Container(
                      width: 86, height: 86,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                          child: Text(_avatar,
                              style: const TextStyle(fontSize: 44))),
                    ),
                    Container(
                      width: 26, height: 26,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.edit, size: 14,
                          color: Color(0xFF4CAF82)),
                    ),
                  ]),
                ),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(_name, style: const TextStyle(
                      color: Colors.white, fontSize: 20,
                      fontWeight: FontWeight.w700)),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _editName,
                    child: const Icon(Icons.edit, color: Colors.white70, size: 16),
                  ),
                ]),
                const SizedBox(height: 16),
                // 3개 데이터
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  _ProfileStat(value: '${_habits.length}', label: '습관 수'),
                  _divider(),
                  _ProfileStat(value: '$totalDone', label: '누적 체크인'),
                  _divider(),
                  _ProfileStat(
                      value: '${(avgRate * 100).round()}%',
                      label: '평균 완료율'),
                ]),
              ]),
            ),

            const SizedBox(height: 16),

            // ── 설정 그룹 ──
            _SettingGroup(title: '환경 설정', items: [
              _SettingTile(
                icon: Icons.timer_outlined,
                iconColor: const Color(0xFF4CAF82),
                title: '집중 시간',
                subtitle: '$_pomoDuration 분',
                onTap: _editPomoDuration,
              ),
              _SettingTile(
                icon: Icons.notifications_outlined,
                iconColor: const Color(0xFF2196F3),
                title: '습관 알림',
                subtitle: _notifyEnabled ? '켜짐' : '꺼짐',
                trailing: Switch(
                  value: _notifyEnabled,
                  activeColor: const Color(0xFF4CAF82),
                  onChanged: (v) => setState(() => _notifyEnabled = v),
                ),
              ),
              _SettingTile(
                icon: Icons.dark_mode_outlined,
                iconColor: const Color(0xFF9C27B0),
                title: '다크 모드',
                subtitle: '개발 중',
                trailing: Switch(
                  value: _darkMode,
                  activeColor: const Color(0xFF4CAF82),
                  onChanged: (v) => setState(() => _darkMode = v),
                ),
              ),
            ]),

            const SizedBox(height: 12),

            _SettingGroup(title: '앱 정보', items: [
              _SettingTile(
                icon: Icons.info_outline,
                iconColor: const Color(0xFF607D8B),
                title: '버전',
                subtitle: 'v1.0.0 (데모)',
              ),
              _SettingTile(
                icon: Icons.school_outlined,
                iconColor: const Color(0xFFFF9800),
                title: '프로젝트 소개',
                subtitle: 'Rhythm Campus — SW센터 산학협력',
                onTap: () => showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Rhythm Campus 소개'),
                    content: const Text(
                      'Rhythm Campus는 Flutter 기반의 자기관리 앱입니다.\n'
                          '간결한 인터페이스와 데이터 피드백으로\n'
                          '대학생의 학습·생활 리듬을 맞춤 설계합니다.\n\n'
                          'SW센터 산학협력 프로젝트입니다.',
                    ),
                    actions: [
                      FilledButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('확인')),
                    ],
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 12),

            _SettingGroup(title: '데이터', items: [
              _SettingTile(
                icon: Icons.delete_outline,
                iconColor: Colors.red,
                title: '모든 데이터 삭제',
                subtitle: '모든 습관 및 체크인 기록 삭제',
                onTap: _showResetConfirm,
                titleColor: Colors.red,
              ),
            ]),

            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }

  Widget _divider() => Container(
      height: 30, width: 1, color: Colors.white.withOpacity(0.3));
}

class _ProfileStat extends StatelessWidget {
  final String value, label;
  const _ProfileStat({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: const TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    ]);
  }
}

class _SettingGroup extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _SettingGroup({required this.title, required this.items});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant)),
        ),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(children: List.generate(items.length, (i) => Column(
            children: [
              items[i],
              if (i < items.length - 1)
                Divider(height: 1, indent: 56,
                    color: cs.outlineVariant.withOpacity(0.4)),
            ],
          ))),
        ),
      ]),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  const _SettingTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w500,
          color: titleColor ?? cs.onSurface)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: TextStyle(
          fontSize: 12, color: cs.onSurfaceVariant))
          : null,
      trailing: trailing ?? (onTap != null
          ? Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 20)
          : null),
    );
  }
}

// ═══════════════════════════════
class _PlaceholderPage extends StatelessWidget {
  final String icon, title, note;
  const _PlaceholderPage({required this.icon, required this.title, required this.note});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(icon, style: const TextStyle(fontSize:56)),
        const SizedBox(height:16),
        Text(title, style: Theme.of(context).textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height:8),
        Text('（$note）', style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ])),
    );
  }
}

// ══════════════════════════════════════════
// 한국어 위젯 헬퍼
// ══════════════════════════════════════════
// 使用方法: BiText('中文', '한국어')
class BiText extends StatelessWidget {
  final String zh;
  final String ko;
  final TextStyle? style;
  final TextAlign? textAlign;
  const BiText(this.zh, this.ko, {super.key, this.style, this.textAlign});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(zh, style: style, textAlign: textAlign),
        Text(ko,
            style: (style ?? const TextStyle()).copyWith(
              fontSize: ((style?.fontSize ?? 14) * 0.82),
              color: (style?.color ?? Colors.grey).withOpacity(0.65),
            ),
            textAlign: textAlign),
      ],
    );
  }
}

// ═══════════════════════════════
//  🌱 식물 성장 위젯
// ═══════════════════════════════
class PlantWidget extends StatefulWidget {
  final double progress; // 0.0 ~ 1.0
  const PlantWidget({super.key, required this.progress});

  @override
  State<PlantWidget> createState() => _PlantWidgetState();
}

class _PlantWidgetState extends State<PlantWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  double _prevProgress = 0;

  // 성장 단계별 식물 정보
  static const _stages = [
    {'emoji': '🌱', 'label': '씨앗', 'color': Color(0xFF8BC34A)},
    {'emoji': '🌿', 'label': '새싹', 'color': Color(0xFF4CAF50)},
    {'emoji': '🪴', 'label': '화분', 'color': Color(0xFF2E9E6B)},
    {'emoji': '🌳', 'label': '나무', 'color': Color(0xFF1B7A4A)},
    {'emoji': '🌸', 'label': '만개！', 'color': Color(0xFFE91E8C)},
  ];

  int get _stageIndex {
    if (widget.progress <= 0)   return 0;
    if (widget.progress < 0.25) return 1;
    if (widget.progress < 0.5)  return 2;
    if (widget.progress < 1.0)  return 3;
    return 4;
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35)
          .chain(CurveTween(curve: Curves.easeOut)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0)
          .chain(CurveTween(curve: Curves.elasticOut)), weight: 60),
    ]).animate(_ctrl);
    _prevProgress = widget.progress;
  }

  @override
  void didUpdateWidget(PlantWidget old) {
    super.didUpdateWidget(old);
    // 진행률이 올라갈 때만 튕김 애니메이션
    if (widget.progress > _prevProgress) {
      _ctrl.forward(from: 0);
    }
    _prevProgress = widget.progress;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stage = _stages[_stageIndex];
    final color = stage['color'] as Color;

    return Tooltip(
      message: '오늘 진행률 ${(widget.progress * 100).round()}% — ${stage['label']}',
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.35), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(stage['emoji'] as String,
                  style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 2),
              Text(stage['label'] as String,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════
//  🎉 폭죽 오버레이 (전체 완료 시)
// ═══════════════════════════════
class ConfettiOverlay extends StatelessWidget {
  final Animation<double> animation;
  const ConfettiOverlay({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(animation.value),
        );
      },
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress; // 0.0 ~ 1.0
  _ConfettiPainter(this.progress);

  static final _rng = math.Random(42);
  static final _particles = List.generate(60, (i) => _ConfettiParticle(
    x: _rng.nextDouble(),
    delay: _rng.nextDouble() * 0.3,
    speed: 0.4 + _rng.nextDouble() * 0.6,
    size: 5 + _rng.nextDouble() * 7,
    color: [
      const Color(0xFF4CAF82),
      const Color(0xFFFFD700),
      const Color(0xFFFF6B9D),
      const Color(0xFF64B5F6),
      const Color(0xFFFF8A65),
      const Color(0xFFBA68C8),
    ][i % 6],
    angle: _rng.nextDouble() * math.pi * 2,
    spin: (_rng.nextDouble() - 0.5) * 8,
  ));

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final t = ((progress - p.delay) / p.speed).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final x = p.x * size.width;
      final y = -30 + t * (size.height * 1.2);
      final opacity = t < 0.7 ? 1.0 : (1.0 - t) / 0.3;

      final paint = Paint()
        ..color = p.color.withOpacity(opacity.clamp(0, 1))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.angle + p.spin * t);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero,
              width: p.size, height: p.size * 0.5),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

class _ConfettiParticle {
  final double x, delay, speed, size, angle, spin;
  final Color color;
  const _ConfettiParticle({
    required this.x, required this.delay, required this.speed,
    required this.size, required this.color, required this.angle,
    required this.spin,
  });
}

// ═══════════════════════════════
//  👥 친구 랭킹 페이지 (완성판)
// ═══════════════════════════════

// 친구 데이터 모델
class Friend {
  final String name;
  final String avatar;
  double todayRate;
  final double weekRate;
  final int streak;
  final int totalCheckins;
  bool isMe;
  bool isCheered;
  int cheerCount;
  final String statusMsg;

  Friend({
    required this.name,
    required this.avatar,
    required this.todayRate,
    required this.weekRate,
    required this.streak,
    required this.totalCheckins,
    this.isMe = false,
    this.isCheered = false,
    this.cheerCount = 0,
    this.statusMsg = '',
  });
}

// 활동 피드 모델
class ActivityFeed {
  final String avatar;
  final String name;
  final String action;
  final String time;
  ActivityFeed({required this.avatar, required this.name,
    required this.action, required this.time});
}

// 샘플 친구 데이터
final List<Friend> _friends = [
  Friend(name:'김지현', avatar:'👩‍🎓', todayRate:1.0,  weekRate:0.92, streak:14, totalCheckins:88, cheerCount:5, statusMsg:'오늘도 완벽！🔥'),
  Friend(name:'이준호', avatar:'🧑‍💻', todayRate:0.8,  weekRate:0.85, streak:7,  totalCheckins:72, cheerCount:3, statusMsg:'코딩+습관 동시에'),
  Friend(name:'나 (조원B)', avatar:'🧑‍🎓', todayRate:0.6, weekRate:0.78, streak:5, totalCheckins:60, isMe:true, statusMsg:'매일 성장 중 🌱'),
  Friend(name:'박소연', avatar:'👩',   todayRate:0.6,  weekRate:0.74, streak:3,  totalCheckins:55, cheerCount:2, statusMsg:'화이팅！'),
  Friend(name:'최민준', avatar:'🧑',   todayRate:0.4,  weekRate:0.65, streak:2,  totalCheckins:41, cheerCount:1, statusMsg:'열심히 할게요'),
  Friend(name:'정하은', avatar:'👩‍💻', todayRate:0.2,  weekRate:0.50, streak:1,  totalCheckins:30, cheerCount:0, statusMsg:'오늘부터 다시！'),
  Friend(name:'한동욱', avatar:'🧑‍🎓', todayRate:0.0,  weekRate:0.42, streak:0,  totalCheckins:22, cheerCount:0, statusMsg:''),
];

// 활동 피드 데이터
final List<ActivityFeed> _feeds = [
  ActivityFeed(avatar:'👩‍🎓', name:'김지현', action:'오늘 습관 5개를 모두 완료했어요 🎉', time:'방금 전'),
  ActivityFeed(avatar:'🧑‍💻', name:'이준호', action:'포모도로 3개 완료！집중력 ↑', time:'10분 전'),
  ActivityFeed(avatar:'👩',   name:'박소연', action:'연속 3일 달성 🔥', time:'1시간 전'),
  ActivityFeed(avatar:'🧑',   name:'최민준', action:'영어 기사 읽기 체크인', time:'2시간 전'),
  ActivityFeed(avatar:'👩‍💻', name:'정하은', action:'아침 조깅 완료！날씨 맑음 ☀️', time:'3시간 전'),
];

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});
  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  int _sortMode = 0; // 0=오늘, 1=이번 주, 2=누적

  List<Friend> get _sorted {
    final list = List<Friend>.from(_friends);
    if (_sortMode == 0) list.sort((a,b) => b.todayRate.compareTo(a.todayRate));
    if (_sortMode == 1) list.sort((a,b) => b.weekRate.compareTo(a.weekRate));
    if (_sortMode == 2) list.sort((a,b) => b.totalCheckins.compareTo(a.totalCheckins));
    return list;
  }

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) setState(() => _sortMode = _tabCtrl.index);
    });
    // 내 오늘 완료율을 실제 습관 데이터와 동기화
    _syncMyRate();
  }

  void _syncMyRate() {
    final done = _habits.where((h) => h.isDone).length;
    final total = _habits.length;
    final me = _friends.firstWhere((f) => f.isMe);
    me.todayRate = total == 0 ? 0 : done / total;
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // 응원 버튼
  void _cheer(Friend f) {
    setState(() {
      f.isCheered = !f.isCheered;
      f.cheerCount += f.isCheered ? 1 : -1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(f.isCheered
            ? '${f.name}에게 응원을 보냈어요 💚'
            : '응원을 취소했어요'),
        backgroundColor: f.isCheered
            ? const Color(0xFF4CAF82)
            : Colors.grey,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // 친구 프로필 상세 보기
  void _showProfile(Friend f, int rank) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // 핸들
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // 아바타 + 이름
          Text(f.avatar, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(f.name, style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700)),
            if (f.isMe) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal:8, vertical:2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF82),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('나', style: TextStyle(
                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ]),
          if (f.statusMsg.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(f.statusMsg, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
          ],
          const SizedBox(height: 4),
          Text('현재 $rank위', style: TextStyle(
              color: rank <= 3
                  ? [const Color(0xFFFFD700), const Color(0xFF9E9E9E), const Color(0xFFCD7F32)][rank-1]
                  : const Color(0xFF4CAF82),
              fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          // 스탯 카드 3개
          Row(children: [
            _StatCard(label: '오늘 완료율', value: '${(f.todayRate*100).round()}%', icon: '🎯', color: const Color(0xFF4CAF82)),
            const SizedBox(width: 10),
            _StatCard(label: '이번 주 평균', value: '${(f.weekRate*100).round()}%', icon: '📅', color: const Color(0xFF2196F3)),
            const SizedBox(width: 10),
            _StatCard(label: '연속 체크인', value: '${f.streak}일', icon: '🔥', color: Colors.orange),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _StatCard(label: '누적 체크인', value: '${f.totalCheckins}회', icon: '✅', color: const Color(0xFF4CAF82)),
            const SizedBox(width: 10),
            _StatCard(label: '받은 응원', value: '${f.cheerCount}개', icon: '💚', color: Colors.pink),
            const SizedBox(width: 10),
            _StatCard(label: '랭킹', value: '$rank위', icon: '🏆', color: const Color(0xFFFFD700)),
          ]),
          const SizedBox(height: 20),
          // 응원 버튼 (자신 아니면 표시)
          if (!f.isMe)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _cheer(f);
                },
                icon: Text(f.isCheered ? '💚' : '👏',
                    style: const TextStyle(fontSize: 16)),
                label: Text(f.isCheered ? '응원 취소' : '응원 보내기'),
                style: FilledButton.styleFrom(
                  backgroundColor: f.isCheered
                      ? Colors.grey
                      : const Color(0xFF4CAF82),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
        ]),
      ),
    );
  }

  // 친구 추가 다이얼로그
  void _showAddFriend() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('친구 추가'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              labelText: '친구 코드 또는 이름',
              border: OutlineInputBorder(),
              hintText: '예: RC-2024-0123',
              prefixIcon: Icon(Icons.person_add_outlined),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF82).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF4CAF82).withOpacity(0.2)),
            ),
            child: Row(children: [
              const Text('나의 코드: ', style: TextStyle(fontSize: 13)),
              const Text('RC-2024-0042',
                  style: TextStyle(fontWeight: FontWeight.w700,
                      color: Color(0xFF2E9E6B), fontSize: 13)),
              const Spacer(),
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('코드 복사됨！'),
                      backgroundColor: Color(0xFF4CAF82),
                      duration: Duration(seconds:1)),
                ),
                child: const Icon(Icons.copy, size: 16, color: Color(0xFF4CAF82)),
              ),
            ]),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('친구 요청을 보냈어요！'),
                  backgroundColor: Color(0xFF4CAF82),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('요청 보내기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _syncMyRate();
    final cs = Theme.of(context).colorScheme;
    final sorted = _sorted;
    final myRank = sorted.indexWhere((f) => f.isMe) + 1;
    final me = _friends.firstWhere((f) => f.isMe);

    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 랭킹'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _showAddFriend,
            icon: const Icon(Icons.person_add_outlined),
            tooltip: '친구 추가',
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: const Color(0xFF4CAF82),
          indicatorColor: const Color(0xFF4CAF82),
          tabs: const [
            Tab(text: '오늘'),
            Tab(text: '이번 주'),
            Tab(text: '누적'),
          ],
        ),
      ),
      body: Column(children: [
        // ── 내 순위 요약 카드 ──
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF82), Color(0xFF2E9E6B)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            Text(me.avatar, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('내 순위', style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 12)),
                Text('$myRank위 / ${_friends.length}명',
                    style: const TextStyle(color: Colors.white,
                        fontSize: 20, fontWeight: FontWeight.w800)),
                if (me.statusMsg.isNotEmpty)
                  Text(me.statusMsg, style: TextStyle(
                      color: Colors.white.withOpacity(0.7), fontSize: 12)),
              ],
            )),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('오늘 완료율', style: TextStyle(
                  color: Colors.white.withOpacity(0.8), fontSize: 11)),
              Text('${(me.todayRate * 100).round()}%',
                  style: const TextStyle(color: Colors.white,
                      fontSize: 24, fontWeight: FontWeight.w800)),
              Text('🔥 연속 ${me.streak}일', style: TextStyle(
                  color: Colors.white.withOpacity(0.8), fontSize: 11)),
            ]),
          ]),
        ),

        // ── 상위 3명 시상대 ──
        if (_sortMode == 0 || _sortMode == 1)
          _PodiumWidget(sorted: sorted, sortMode: _sortMode),

        // ── 랭킹 리스트 ──
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: sorted.length + 1,
            itemBuilder: (ctx, i) {
              // 마지막 항목 = 활동 피드 헤더
              if (i == sorted.length) {
                return _ActivityFeedSection();
              }

              final f = sorted[i];
              final rank = i + 1;
              final value = _sortMode == 0
                  ? f.todayRate
                  : _sortMode == 1 ? f.weekRate
                  : f.totalCheckins / 100.0;
              final label = _sortMode == 2
                  ? '${f.totalCheckins}회'
                  : '${(_sortMode == 0 ? f.todayRate : f.weekRate) * 100 ~/ 1}%';

              return GestureDetector(
                onTap: () => _showProfile(f, rank),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: f.isMe
                        ? const Color(0xFF4CAF82).withOpacity(0.08)
                        : cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: f.isMe
                          ? const Color(0xFF4CAF82).withOpacity(0.4)
                          : rank <= 3
                          ? [
                        const Color(0xFFFFD700),
                        const Color(0xFFC0C0C0),
                        const Color(0xFFCD7F32),
                      ][rank - 1].withOpacity(0.4)
                          : cs.outlineVariant.withOpacity(0.2),
                      width: f.isMe || rank <= 3 ? 1.5 : 1,
                    ),
                  ),
                  child: Row(children: [
                    // 순위 메달
                    SizedBox(
                      width: 32,
                      child: rank <= 3
                          ? Text(['🥇', '🥈', '🥉'][rank - 1],
                          style: const TextStyle(fontSize: 22),
                          textAlign: TextAlign.center)
                          : Text('$rank',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700,
                              color: cs.onSurfaceVariant),
                          textAlign: TextAlign.center),
                    ),
                    const SizedBox(width: 8),
                    // 아바타
                    Text(f.avatar, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    // 이름 + 진행바
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(f.name, style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600,
                              color: f.isMe
                                  ? const Color(0xFF2E9E6B)
                                  : cs.onSurface)),
                          if (f.isMe) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF82),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text('나', style: TextStyle(
                                  color: Colors.white, fontSize: 9,
                                  fontWeight: FontWeight.w700)),
                            ),
                          ],
                          if (f.cheerCount > 0) ...[
                            const SizedBox(width: 4),
                            Text('💚${f.cheerCount}',
                                style: TextStyle(fontSize: 11,
                                    color: cs.onSurfaceVariant)),
                          ],
                        ]),
                        const SizedBox(height: 3),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: value.clamp(0.0, 1.0),
                            backgroundColor: cs.outlineVariant.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              rank == 1 ? const Color(0xFFFFD700)
                                  : rank == 2 ? const Color(0xFF9E9E9E)
                                  : rank == 3 ? const Color(0xFFCD7F32)
                                  : const Color(0xFF4CAF82),
                            ),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    )),
                    const SizedBox(width: 10),
                    // 수치 + 연속
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(label, style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: rank <= 3
                              ? [const Color(0xFFFFD700),
                            const Color(0xFF9E9E9E),
                            const Color(0xFFCD7F32)][rank - 1]
                              : const Color(0xFF4CAF82))),
                      Text('🔥 ${f.streak}일',
                          style: TextStyle(fontSize: 11,
                              color: cs.onSurfaceVariant)),
                    ]),
                    const SizedBox(width: 8),
                    // 응원 버튼
                    if (!f.isMe)
                      GestureDetector(
                        onTap: () => _cheer(f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: f.isCheered
                                ? const Color(0xFF4CAF82).withOpacity(0.15)
                                : cs.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: f.isCheered
                                  ? const Color(0xFF4CAF82)
                                  : cs.outlineVariant.withOpacity(0.3),
                            ),
                          ),
                          child: Center(
                            child: Text(f.isCheered ? '💚' : '👏',
                                style: const TextStyle(fontSize: 16)),
                          ),
                        ),
                      ),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

// ── 시상대 위젯 (상위 3명) ──
class _PodiumWidget extends StatelessWidget {
  final List<Friend> sorted;
  final int sortMode;
  const _PodiumWidget({required this.sorted, required this.sortMode});

  @override
  Widget build(BuildContext context) {
    if (sorted.length < 3) return const SizedBox.shrink();
    final top3 = sorted.take(3).toList();
    // 순서: 2위(왼), 1위(가운데), 3위(오른)
    final order = [top3[1], top3[0], top3[2]];
    final heights = [80.0, 110.0, 60.0];
    final colors = [const Color(0xFFC0C0C0), const Color(0xFFFFD700), const Color(0xFFCD7F32)];
    final labels = ['🥈', '🥇', '🥉'];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(3, (i) {
          final f = order[i];
          final val = sortMode == 0
              ? '${(f.todayRate * 100).round()}%'
              : '${(f.weekRate * 100).round()}%';
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(f.avatar, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 2),
                Text(f.name.length > 4 ? f.name.substring(0, 4) : f.name,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                Text(val, style: TextStyle(
                    fontSize: 12, color: colors[i], fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Container(
                  height: heights[i],
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: colors[i].withOpacity(0.85),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: Center(
                    child: Text(labels[i], style: const TextStyle(fontSize: 20)),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── 활동 피드 섹션 ──
class _ActivityFeedSection extends StatelessWidget {
  const _ActivityFeedSection();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text('친구 활동 피드', style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700)),
      ),
      ..._feeds.map((f) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Text(f.avatar, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(f.name, style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
              Text(f.action, style: TextStyle(
                  fontSize: 12, color: cs.onSurfaceVariant)),
            ],
          )),
          Text(f.time, style: TextStyle(
              fontSize: 11, color: cs.onSurfaceVariant)),
        ]),
      )),
      const SizedBox(height: 16),
    ]);
  }
}