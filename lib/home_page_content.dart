import 'package:flutter/material.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({
    super.key,
    required this.onGoToTask,
    required this.onGoToAward,
  });

  final VoidCallback onGoToTask;
  final VoidCallback onGoToAward;

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  static const Color bgColor = Color(0xFFF1F8E9);
  static const Color mainGreen = Color(0xFFD1E683);
  static const Color darkCard = Color(0xFF1A1C1E);

  // 纯本地静态数据
  final user = const _User(
    username: "PandaUser",
    level: 1,
    xp: 10,
    totalSignInDays: 5,
  );

  final List<_Task> tasks = const [
    _Task(title: "Morning Workout", timeSlot: "08:00", done: false),
    _Task(title: "Evening Stretch", timeSlot: "19:00", done: true),
  ];

  Future<void> _refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _animatedEntrance(delay: 0, child: _buildHeroHeader()),
              const SizedBox(height: 20),
              _animatedEntrance(delay: 120, child: _buildWeeklySignIn()),
              const SizedBox(height: 20),
              _animatedEntrance(
                delay: 240,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildTotalCheckIns(),
                          const SizedBox(height: 20),
                          _buildExpProgress(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(child: _buildDailyTaskCard()),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _animatedEntrance(delay: 600, child: _buildStartCard()),
            ],
          ),
        ),
      ),
    );
  }

  // 顶部欢迎卡片
  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 31,
            backgroundColor: mainGreen,
            child: const Text(
              'P',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back, PandaUser',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Level ${user.level} • ${user.xp} XP',
                  style: TextStyle(color: Colors.white.withOpacity(0.72)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 每周签到
  Widget _buildWeeklySignIn() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Sign-in Goal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${user.totalSignInDays} / 7 days',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (_) {
              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: mainGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.black, size: 18),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Day',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // 每日任务卡片
  Widget _buildDailyTaskCard() {
    return Container(
      height: 345,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: mainGreen,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Task',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: widget.onGoToTask,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                    color: Color(0xFFD1E683),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: tasks.map((task) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Icon(
                          task.done ? Icons.check_circle : Icons.circle,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            if (task.timeSlot.isNotEmpty)
                              Text(
                                task.timeSlot,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 总签到数
  Widget _buildTotalCheckIns() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed in (local)')),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Check-ins',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Click to sign in',
              style: TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
            SizedBox(height: 12),
            Text(
              '5',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // 经验进度
  Widget _buildExpProgress() {
    final maxExp = user.level * 30;
    final progress = user.xp / maxExp;

    return GestureDetector(
      onTap: widget.onGoToAward,
      child: Container(
        width: double.infinity,
        height: 190,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'EXP Progress',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 84,
                    height: 84,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      color: mainGreen,
                      backgroundColor: Colors.white10,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '${user.xp}/$maxExp',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // 底部运动卡片
  Widget _buildStartCard() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(40),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '120 mins • 8.5 km this week',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: _ScaleTap(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.directions_run,
                      color: Color(0xFFD1E683),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      ' Exercise',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 入场动画
  Widget _animatedEntrance({required Widget child, required int delay}) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: delay)),
      builder: (context, snapshot) {
        final done = snapshot.connectionState == ConnectionState.done;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: done ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
    );
  }
}

// 点击缩放效果
class _ScaleTap extends StatefulWidget {
  const _ScaleTap({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  State<_ScaleTap> createState() => _ScaleTapState();
}

class _ScaleTapState extends State<_ScaleTap> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.94),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}

// 静态数据模型
class _User {
  final String username;
  final int level;
  final int xp;
  final int totalSignInDays;

  const _User({
    required this.username,
    required this.level,
    required this.xp,
    required this.totalSignInDays,
  });
}

class _Task {
  final String title;
  final String timeSlot;
  final bool done;

  const _Task({
    required this.title,
    required this.timeSlot,
    required this.done,
  });
}