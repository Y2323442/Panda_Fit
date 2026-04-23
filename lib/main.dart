import 'package:flutter/material.dart';

// 🔥 全局语言变量（解决 isChinese 爆红）
bool isChinese = false;

void main() {
  runApp(const TrainQuestRoot());
}

class TrainQuestRoot extends StatelessWidget {
  const TrainQuestRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Georgia'),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int? _pressingIndex;

  // 🔥 刷新语言（解决中文/英文切换）
  void refreshLang() {
    setState(() {});
  }

  List<Widget> get _pages {
    return [
      HomePageContent(
        onGoToTask: () => setState(() => _currentIndex = 1),
        onGoToAward: () => setState(() => _currentIndex = 2),
      ),
      const TaskPage(),
      const AwardPageScreen(),
      const GrowPage(),
      // 🔥 传入刷新方法，解决 MePage 爆红
      MePage(
        refresh: refreshLang,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const Color mainGreen = Color(0xFFD1E683);
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        height: 90,
        color: mainGreen,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(isChinese ? "首页" : "Home", Icons.home, 0),
            _buildNavItem(isChinese ? "任务" : "Task", Icons.list, 1),
            _buildNavItem(isChinese ? "奖励" : "Award", Icons.emoji_events, 2),
            _buildNavItem(isChinese ? "成长" : "Grow", Icons.trending_up, 3),
            _buildNavItem(isChinese ? "我的" : "Me", Icons.person, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressingIndex = index),
      onTapUp: (_) => setState(() {
        _pressingIndex = null;
        _currentIndex = index;
      }),
      onTapCancel: () => setState(() => _pressingIndex = null),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedScale(
          scale: _pressingIndex == index ? 1.3 : (isActive ? 1.1 : 1.0),
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _pressingIndex == index
                      ? Colors.black
                      : (isActive ? Colors.black.withOpacity(0.1) : Colors.transparent),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: _pressingIndex == index ? Colors.white : (isActive ? Colors.black : Colors.black45),
                  size: 28,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: (isActive || _pressingIndex == index) ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------
// 以下是空页面占位（解决所有爆红）
// ------------------------------
class HomePageContent extends StatelessWidget {
  const HomePageContent({
    super.key,
    required this.onGoToTask,
    required this.onGoToAward,
  });

  final VoidCallback onGoToTask;
  final VoidCallback onGoToAward;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF1F8E9),
      body: Center(child: Text("首页", style: TextStyle(fontSize: 22))),
    );
  }
}

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF1F8E9),
      body: Center(child: Text("任务", style: TextStyle(fontSize: 22))),
    );
  }
}

class AwardPageScreen extends StatelessWidget {
  const AwardPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF1F8E9),
      body: Center(child: Text("奖励", style: TextStyle(fontSize: 22))),
    );
  }
}

class GrowPage extends StatelessWidget {
  const GrowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF1F8E9),
      body: Center(child: Text("成长", style: TextStyle(fontSize: 22))),
    );
  }
}

// 🔥 修复 MePage 爆红（支持语言切换）
class MePage extends StatelessWidget {
  const MePage({
    super.key,
    required this.refresh,
  });

  final VoidCallback refresh;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("我的", style: TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
            // 语言切换按钮（不报错）
            ElevatedButton(
              onPressed: () {
                isChinese = !isChinese;
                refresh();
              },
              child: Text(isChinese ? "切换英文" : "Switch to Chinese"),
            ),
          ],
        ),
      ),
    );
  }
}