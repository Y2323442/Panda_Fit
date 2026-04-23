import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GrowPage extends StatefulWidget {
  const GrowPage({super.key});

  @override
  State<GrowPage> createState() => _GrowPageState();
}

class _GrowPageState extends State<GrowPage> {
  static const Color bgColor = Color(0xFFF1F8E9);
  static const Color mainGreen = Color(0xFFD1E683);
  static const Color darkCard = Color(0xFF000000);

  String _selectedTab = 'Daily';
  final List<String> _tabs = <String>['Daily', 'Weekly', 'Monthly', 'Quarterly'];
  final PageController _galleryController = PageController();

  bool _loading = false;
  bool _uploading = false;
  String? _error;
  int _galleryIndex = 0;

  // 🔥 本地模拟数据，完全不请求后端
  Map<String, dynamic> mockUser = {
    "level": 1,
    "xp": 10,
    "streakDays": 2,
    "totalSignInDays": 5,
  };

  Map<String, dynamic> mockProgress = {
    "steps": 1200,
    "workoutMinutes": 45,
    "calories": 320,
    "distanceKm": 2.5,
  };

  Map<String, dynamic> mockWeekly = {
    "totalDistance": 12.5,
    "signedDays": 4,
    "completionRate": 80,
    "totalMinutes": 220,
  };

  List<String> localPhotos = [
    'assets/images/basketball.jpg',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _galleryController.dispose();
    super.dispose();
  }

  // 模拟上传图片（实际不传到服务器）
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _uploading = true);
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      localPhotos.add(image.path);
      _uploading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo saved locally')),
      );
    }
  }

  // 模拟更新今日数据（只存在内存）
  Future<void> _updateTodayProgress() async {
    final stepsController = TextEditingController(text: mockProgress['steps'].toString());
    final minutesController = TextEditingController(text: mockProgress['workoutMinutes'].toString());
    final caloriesController = TextEditingController(text: mockProgress['calories'].toString());
    final distanceController = TextEditingController(text: mockProgress['distanceKm'].toStringAsFixed(1));

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Update today progress'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _numberField(controller: stepsController, label: 'Steps'),
              _numberField(controller: minutesController, label: 'Workout minutes'),
              _numberField(controller: caloriesController, label: 'Calories'),
              _numberField(controller: distanceController, label: 'Distance (km)'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () {
              setState(() {
                mockProgress['steps'] = int.tryParse(stepsController.text.trim()) ?? 0;
                mockProgress['workoutMinutes'] = int.tryParse(minutesController.text.trim()) ?? 0;
                mockProgress['calories'] = int.tryParse(caloriesController.text.trim()) ?? 0;
                mockProgress['distanceKm'] = double.tryParse(distanceController.text.trim()) ?? 0.0;
              });
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: mainGreen)),
          ),
        ],
      ),
    );
  }

  // 模拟签到（只在内存）
  Future<void> _signInToday() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signed in successfully (local)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 20),
              const Text(
                'Grow',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
              const SizedBox(height: 8),
              const Text(
                'Track today, keep your streak alive, and upload workout photos.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 25),
              _buildTimeTabs(),
              const SizedBox(height: 25),
              _buildKeepItUpCard(),
              const SizedBox(height: 20),
              _buildImageGallery(),
              const SizedBox(height: 20),
              _buildMetricsSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _tabs.map((tab) {
        final isSelected = _selectedTab == tab;
        return _ScaleTap(
          onTap: () => setState(() => _selectedTab = tab),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: isSelected ? mainGreen : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Text(tab, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeepItUpCard() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Keep It Up', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    _selectedTabMessage,
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const Icon(Icons.emoji_events, color: Colors.amber, size: 70),
          ],
        ),
      ),
    );
  }

  String get _selectedTabMessage {
    switch (_selectedTab) {
      case 'Weekly':
        return 'Streak: ${mockUser["streakDays"]} days\nWeekly: ${mockWeekly["totalMinutes"]} min';
      case 'Monthly':
      case 'Quarterly':
        return 'Level: ${mockUser["level"]}  XP: ${mockUser["xp"]}';
      default:
        return 'Streak: ${mockUser["streakDays"]} days\nKeep going today!';
    }
  }

  Widget _buildImageGallery() {
    return Stack(
      children: [
        SizedBox(
          height: 220,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: PageView.builder(
              controller: _galleryController,
              onPageChanged: (i) => setState(() => _galleryIndex = i),
              itemCount: localPhotos.length,
              itemBuilder: (context, index) {
                final path = localPhotos[index];
                if (path.startsWith('assets/')) {
                  return Image.asset(path, fit: BoxFit.cover);
                } else {
                  return Image.file(File(path), fit: BoxFit.cover);
                }
              },
            ),
          ),
        ),
        Positioned(
          top: 20,
          left: 20,
          child: Row(
            children: List.generate(localPhotos.length, (i) {
              final curr = i == _galleryIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 8),
                width: curr ? 12 : 8,
                height: curr ? 12 : 8,
                decoration: BoxDecoration(color: curr ? Colors.white : Colors.white54, shape: BoxShape.circle),
              );
            }),
          ),
        ),
        Positioned(
          bottom: 15,
          right: 15,
          child: _ScaleTap(
            onTap: _uploading ? () {} : _pickImage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  _uploading
                      ? const SizedBox(width:14,height:14,child: CircularProgressIndicator(strokeWidth:2,color:Colors.white))
                      : const Icon(Icons.add_a_photo, color: Colors.white, size:14),
                  const SizedBox(width:5),
                  Text(_uploading ? 'Uploading...' : 'Add Pictures',
                      style: const TextStyle(color: Colors.white, fontSize:12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsSection() {
    if (_selectedTab == 'Daily') {
      return Column(
        children: [
          _buildTaskCard('Today steps', '${mockProgress["steps"]}', 'Keep walking.', true),
          const SizedBox(height:20),
          _buildTaskCard('Workout minutes', '${mockProgress["workoutMinutes"]} min', 'Calories: ${mockProgress["calories"]}', false),
        ],
      );
    }
    if (_selectedTab == 'Weekly') {
      return Column(
        children: [
          _buildTaskCard('Weekly distance', '${mockWeekly["totalDistance"].toStringAsFixed(1)} KM', 'Signed days: ${mockWeekly["signedDays"]}', true),
          const SizedBox(height:20),
          _buildTaskCard('Completion', '${mockWeekly["completionRate"].toStringAsFixed(0)}%', 'Minutes: ${mockWeekly["totalMinutes"]}', false),
        ],
      );
    }
    return Column(
      children: [
        _buildTaskCard('Level', 'Lv.${mockUser["level"]}', 'XP: ${mockUser["xp"]}', true),
        const SizedBox(height:20),
        _buildTaskCard('Sign-ins', '${mockUser["totalSignInDays"]}', 'Streak: ${mockUser["streakDays"]} days', false),
      ],
    );
  }

  Widget _buildTaskCard(String title, String badgeText, String subtitle, bool right) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: mainGreen, borderRadius: BorderRadius.circular(30)),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: const Color(0xFFF9FFF0), borderRadius: BorderRadius.circular(25)),
        child: Row(
          children: [
            if (!right) _buildBadge(badgeText),
            if (!right) const SizedBox(width:15),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize:15, fontWeight: FontWeight.w600)),
              const SizedBox(height:6),
              Text(subtitle, style: const TextStyle(color: Colors.black54)),
            ])),
            if (right) const SizedBox(width:10),
            if (right) _buildBadge(badgeText),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal:18, vertical:10),
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _numberField({required TextEditingController controller, required String label}) {
    return Padding(
      padding: const EdgeInsets.only(bottom:12),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
      ),
    );
  }
}

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
      onTapDown: (_) => setState(() => _scale = 0.92),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(scale: _scale, duration: const Duration(milliseconds:100), child: widget.child),
    );
  }
}