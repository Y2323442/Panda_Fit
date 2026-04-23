import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'models/trainquest_models.dart';
import 'trainquest_scope.dart';

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

  bool _loading = true;
  bool _uploading = false;
  String? _error;
  DashboardData? _dashboard;
  ProgressRecordModel? _todayProgress;
  List<WorkoutPhotoModel> _photos = <WorkoutPhotoModel>[];
  int _galleryIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _galleryController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool showLoader = true}) async {
    final controller = TrainQuestScope.of(context);

    if (showLoader) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final dashboard = await controller.api.fetchHome(controller.token);
      final todayProgress = await controller.api.fetchTodayProgress(controller.token);
      final photos = await controller.api.fetchPhotos(controller.token);
      await controller.updateUser(dashboard.user);

      if (!mounted) {
        return;
      }

      setState(() {
        _dashboard = dashboard;
        _todayProgress = todayProgress;
        _photos = photos;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _updateTodayProgress() async {
    final progress = _todayProgress;
    if (progress == null) {
      return;
    }

    final stepsController =
        TextEditingController(text: progress.steps.toString());
    final minutesController =
        TextEditingController(text: progress.workoutMinutes.toString());
    final caloriesController =
        TextEditingController(text: progress.calories.toString());
    final distanceController =
        TextEditingController(text: progress.distanceKm.toStringAsFixed(1));

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Update today progress'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _numberField(controller: stepsController, label: 'Steps'),
              _numberField(
                controller: minutesController,
                label: 'Workout minutes',
              ),
              _numberField(controller: caloriesController, label: 'Calories'),
              _numberField(
                controller: distanceController,
                label: 'Distance (km)',
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () async {
              final controller = TrainQuestScope.of(context);

              try {
                await controller.api.updateTodayProgress(
                  controller.token,
                  steps: int.tryParse(stepsController.text.trim()) ?? 0,
                  workoutMinutes:
                      int.tryParse(minutesController.text.trim()) ?? 0,
                  calories: int.tryParse(caloriesController.text.trim()) ?? 0,
                  distanceKm:
                      double.tryParse(distanceController.text.trim()) ?? 0,
                );

                if (!mounted) {
                  return;
                }

                Navigator.pop(context);
                await _loadData(showLoader: false);
              } catch (error) {
                if (!mounted) {
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error.toString())),
                );
              }
            },
            child: const Text('Save', style: TextStyle(color: mainGreen)),
          ),
        ],
      ),
    );
  }

  Future<void> _signInToday() async {
    final controller = TrainQuestScope.of(context);

    try {
      final result = await controller.api.signInToday(controller.token);
      await controller.updateUser(result.user);

      if (!mounted) {
        return;
      }

      await _loadData(showLoader: false);

      final badgeMessage = result.newBadges.isEmpty
          ? 'Signed in successfully.'
          : 'Signed in successfully. New badges: ${result.newBadges.join(', ')}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(badgeMessage)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _pickImage() async {
    final controller = TrainQuestScope.of(context);
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      return;
    }

    setState(() => _uploading = true);

    try {
      await controller.api.uploadPhoto(
        controller.token,
        File(image.path),
        caption: 'Workout moment',
      );

      if (!mounted) {
        return;
      }

      await _loadData(showLoader: false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo uploaded successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _loadData(showLoader: false),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: <Widget>[
              const SizedBox(height: 20),
              const Text(
                'Grow',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Track today, keep your streak alive, and upload workout photos.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 25),
              _buildTimeTabs(),
              const SizedBox(height: 25),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                _buildErrorCard()
              else ...<Widget>[
                _buildKeepItUpCard(),
                const SizedBox(height: 20),
                _buildImageGallery(),
                const SizedBox(height: 20),
                _buildMetricsSection(),
                const SizedBox(height: 20),
                
              ],
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
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              tab,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeepItUpCard() {
    final dashboard = _dashboard!;
    final user = dashboard.user;
    final summary = dashboard.weeklySummary;
    final messages = <String>[
      'Streak: ${user.streakDays} days\nStay consistent today.',
      'This week: ${summary.totalMinutes} minutes\nKeep your momentum strong.',
      'XP: ${user.xp}\nYour backend progress is syncing live.',
    ];

    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(40),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Keep It Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    messages[_tabMessageIndex],
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                      height: 1.4,
                    ),
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

  int get _tabMessageIndex {
    switch (_selectedTab) {
      case 'Weekly':
        return 1;
      case 'Monthly':
      case 'Quarterly':
        return 2;
      case 'Daily':
      default:
        return 0;
    }
  }

  Widget _buildImageGallery() {
    final controller = TrainQuestScope.of(context);

    return Stack(
      children: <Widget>[
        SizedBox(
          height: 220,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: PageView.builder(
              controller: _galleryController,
              onPageChanged: (index) => setState(() => _galleryIndex = index),
              itemCount: _photos.isEmpty ? 1 : _photos.length,
              itemBuilder: (context, index) {
                if (_photos.isEmpty) {
                  return Image.asset(
                    'assets/images/basketball.jpg',
                    fit: BoxFit.cover,
                  );
                }

                final photo = _photos[index];
                return Image.network(
                  photo.imageUrl(controller.baseUrl),
                  fit: BoxFit.cover,
                  headers: <String, String>{
                    'Authorization': 'Bearer ${controller.token}',
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.black12,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image, size: 44),
                    );
                  },
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 20,
          left: 20,
          child: Row(
            children: List<Widget>.generate(
              _photos.isEmpty ? 1 : _photos.length,
              (index) {
                final isCurrent = index == _galleryIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 8),
                  width: isCurrent ? 12 : 8,
                  height: isCurrent ? 12 : 8,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 15,
          right: 15,
          child: _ScaleTap(
            onTap: _uploading ? () {} : _pickImage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: <Widget>[
                  _uploading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.add_a_photo,
                          color: Colors.white,
                          size: 14,
                        ),
                  const SizedBox(width: 5),
                  Text(
                    _uploading ? 'Uploading...' : 'Add Pictures',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsSection() {
    final progress = _todayProgress!;
    final summary = _dashboard!.weeklySummary;

    if (_selectedTab == 'Daily') {
      return Column(
        children: <Widget>[
          _buildTaskCard(
            'Today steps',
            '${progress.steps}',
            'Keep walking and stay active.',
            true,
          ),
          const SizedBox(height: 20),
          _buildTaskCard(
            'Workout minutes',
            '${progress.workoutMinutes} min',
            'Calories: ${progress.calories}',
            false,
          ),
        ],
      );
    }

    if (_selectedTab == 'Weekly') {
      return Column(
        children: <Widget>[
          _buildTaskCard(
            'Weekly distance',
            '${summary.totalDistance.toStringAsFixed(1)} KM',
            'Signed days: ${summary.signedDays}',
            true,
          ),
          const SizedBox(height: 20),
          _buildTaskCard(
            'Task completion',
            '${summary.completionRate.toStringAsFixed(0)}%',
            'Minutes trained: ${summary.totalMinutes}',
            false,
          ),
        ],
      );
    }

    final user = _dashboard!.user;
    return Column(
      children: <Widget>[
        _buildTaskCard(
          'Current level',
          'Lv.${user.level}',
          'XP collected: ${user.xp}',
          true,
        ),
        const SizedBox(height: 20),
        _buildTaskCard(
          'Total sign-ins',
          '${user.totalSignInDays}',
          'Current streak: ${user.streakDays} days',
          false,
        ),
      ],
    );
  }

 
  Widget _buildTaskCard(
    String title,
    String badgeText,
    String subtitle,
    bool right,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: mainGreen,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FFF0),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: <Widget>[
            if (!right) _buildBadge(badgeText),
            if (!right) const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            if (right) const SizedBox(width: 10),
            if (right) _buildBadge(badgeText),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: <Widget>[
          const Icon(Icons.error_outline, size: 42, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(
            _error ?? 'Could not load grow data.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () => _loadData(),
            child: const Text('Retry', style: TextStyle(color: mainGreen)),
          ),
        ],
      ),
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 0,
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ScaleTap extends StatefulWidget {
  const _ScaleTap({
    required this.child,
    required this.onTap,
  });

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
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
