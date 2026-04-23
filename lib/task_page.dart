import 'package:flutter/material.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  static const Color bgColor = Color(0xFFF1F8E9);
  static const Color mainGreen = Color(0xFFD1E683);
  static const Color darkCard = Color(0xFF1A1C1E);

  int _selectedTab = 0;
  bool _loading = false;
  String? _error;

  // 本地任务（纯静态）
  List<LocalTask> _dailyTasks = [
    LocalTask(
      id: 1,
      title: "Morning Workout",
      description: "",
      timeSlot: "08:00",
      status: "active",
      category: "daily",
    ),
    LocalTask(
      id: 2,
      title: "Evening Stretch",
      description: "",
      timeSlot: "19:00",
      status: "completed",
      category: "daily",
    ),
  ];

  List<LocalTask> _projects = [
    LocalTask(
      id: 3,
      title: "Fitness Plan",
      description: "Weekly training goal",
      timeSlot: "",
      status: "active",
      category: "project",
    ),
  ];

  int _nextId = 4;

  @override
  void initState() {
    super.initState();
    _sortDailyTasks();
  }

  Future<void> _loadData({bool showLoader = true}) async {
    setState(() {});
  }

  void _sortDailyTasks() {
    _dailyTasks.sort((a, b) {
      final t1 = _parseTimeOfDay(a.timeSlot);
      final t2 = _parseTimeOfDay(b.timeSlot);
      final total1 = t1.hour * 60 + t1.minute;
      final total2 = t2.hour * 60 + t2.minute;
      return total1.compareTo(total2);
    });
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
    try {
      final s = timeStr.trim().toLowerCase();
      final match = RegExp(
        r'(\d{1,2}):?(\d{0,2})\s*(am|pm)?',
        caseSensitive: false,
      ).firstMatch(s);

      if (match == null) return const TimeOfDay(hour: 23, minute: 59);

      var hour = int.parse(match.group(1)!);
      final minute = int.tryParse(match.group(2) ?? '0') ?? 0;
      final period = match.group(3);

      if (period == 'pm') {
        if (hour < 12) hour += 12;
      } else if (period == 'am') {
        if (hour == 12) hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return const TimeOfDay(hour: 23, minute: 59);
    }
  }

  Future<void> _showAddDialog() async {
    final titleController = TextEditingController();
    TimeOfDay? selectedTime = TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              _selectedTab == 0 ? 'Add Daily Task' : 'Add Project',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Title',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_selectedTab == 0)
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime!,
                      );
                      if (picked != null) {
                        setStateDialog(() {
                          selectedTime = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(selectedTime!.format(context)),
                          const Icon(Icons.access_time),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: () {
                  final title = titleController.text.trim();
                  if (title.isEmpty) return;

                  setState(() {
                    if (_selectedTab == 0) {
                      _dailyTasks.add(
                        LocalTask(
                          id: _nextId++,
                          title: title,
                          description: "",
                          timeSlot: selectedTime!.format(context),
                          status: "active",
                          category: "daily",
                        ),
                      );
                      _sortDailyTasks();
                    } else {
                      _projects.add(
                        LocalTask(
                          id: _nextId++,
                          title: title,
                          description: "",
                          timeSlot: "",
                          status: "active",
                          category: "project",
                        ),
                      );
                    }
                  });

                  Navigator.pop(context);
                },
                child: Text('Add', style: TextStyle(color: mainGreen)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _toggleComplete(LocalTask task) async {
    setState(() {
      task.status = task.status == 'completed' ? 'active' : 'completed';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(task.status == 'completed' ? 'Marked as completed' : 'Completed canceled'),
        backgroundColor: Colors.black,
      ),
    );
  }

  Future<void> _deleteTask(LocalTask task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete task?'),
        content: Text('Delete "${task.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete', style: TextStyle(color: mainGreen)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    setState(() {
      _dailyTasks.removeWhere((t) => t.id == task.id);
      _projects.removeWhere((t) => t.id == task.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Task',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Manage your daily tasks and projects',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  _buildTabs(),
                  const SizedBox(height: 24),
                  if (_error != null)
                    _buildErrorCard()
                  else
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: _selectedTab == 0 ? _buildDailyList() : _buildProjectList(),
                    ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _ScaleTap(
                onTap: _showAddDialog,
                child: Container(
                  height: 66,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded, color: mainGreen, size: 26),
                      SizedBox(width: 10),
                      Text(
                        'Add New Record',
                        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        _tabButton('Daily Task', 0),
        const SizedBox(width: 14),
        _tabButton('Project', 1),
      ],
    );
  }

  Widget _tabButton(String label, int index) {
    final active = _selectedTab == index;
    return _ScaleTap(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? mainGreen : Colors.black54,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildDailyList() {
    if (_dailyTasks.isEmpty) {
      return _buildEmptyCard('No daily tasks yet', 'Add your first task to get started');
    }
    return Column(
      key: const ValueKey(0),
      children: [for (final task in _dailyTasks) _buildDailyItem(task)],
    );
  }

  Widget _buildDailyItem(LocalTask task) {
    final done = task.status == 'completed';
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: done ? mainGreen : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: done ? mainGreen : Colors.black12, width: 3),
                ),
              ),
              Expanded(child: Container(width: 2, color: Colors.black12)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _ScaleTap(
              onTap: () => _toggleComplete(task),
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: done ? Colors.black12 : darkCard,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.timeSlot.isNotEmpty ? task.timeSlot : 'Any time',
                            style: TextStyle(color: done ? Colors.black45 : mainGreen, fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            task.title,
                            style: TextStyle(color: done ? Colors.black38 : Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _deleteTask(task),
                      icon: Icon(Icons.delete_outline, color: done ? Colors.black45 : Colors.white54),
                    ),
                    if (done) const Icon(Icons.check_circle, color: mainGreen, size: 26),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectList() {
    if (_projects.isEmpty) {
      return _buildEmptyCard('No projects yet', 'Create a project to track long-term goals');
    }
    return Column(
      key: const ValueKey(1),
      children: [for (final task in _projects) _buildProjectCard(task)],
    );
  }

  Widget _buildProjectCard(LocalTask task) {
    final done = task.status == 'completed';
    final progress = done ? 1.0 : 0.35;

    return _ScaleTap(
      onTap: () => _toggleComplete(task),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(task.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ),
                IconButton(onPressed: () => _deleteTask(task), icon: const Icon(Icons.delete_outline, color: Colors.black38)),
              ],
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(task.description, style: const TextStyle(color: Colors.black54)),
            ],
            const SizedBox(height: 18),
            Stack(
              children: [
                Container(height: 10, decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8))),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(height: 10, decoration: BoxDecoration(color: mainGreen, borderRadius: BorderRadius.circular(8))),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(done ? 'Completed' : 'In progress', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: mainGreen)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 44, color: Colors.black38),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 6),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 44, color: Colors.redAccent),
          const SizedBox(height: 16),
          const Text('Failed to load tasks', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 18),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: _loadData,
            child: const Text('Retry', style: TextStyle(color: mainGreen)),
          ),
        ],
      ),
    );
  }
}

class _ScaleTap extends StatefulWidget {
  const _ScaleTap({super.key, required this.child, required this.onTap});
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
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

// 本地静态任务模型（解决所有报错）
class LocalTask {
  final int id;
  final String title;
  final String description;
  final String timeSlot;
  String status;
  final String category;

  LocalTask({
    required this.id,
    required this.title,
    required this.description,
    required this.timeSlot,
    required this.status,
    required this.category,
  });
}