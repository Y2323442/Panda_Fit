import 'package:flutter/material.dart';

import 'about_page.dart';
import 'language_page.dart';
import 'notification_page.dart';
import 'premium_page.dart';
import 'security_page.dart';
import 'support_page.dart';
import 'trainquest_scope.dart';
import 'main.dart'; // 👈 已经引入，能读到 isChinese 了

class MePage extends StatefulWidget {
  const MePage({super.key});

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  static const Color bgColor = Color(0xFFF1F8E9); // 浅绿背景
  static const Color mainGreen = Color(0xFFD1E683);
  static const Color darkCard = Color(0xFF1A1C1E);

  @override
  Widget build(BuildContext context) {
    final controller = TrainQuestScope.of(context);
    final user = controller.user;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _animatedEntrance(
                delay: 0,
                child: Text(
                  isChinese ? "我的" : "Me",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              _animatedEntrance(
                delay: 100,
                child: _buildProfileCard(
                  userName: user?.username ?? 'TrainQuest User',
                  email: user?.email ?? '',
                  level: user?.level ?? 1,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _animatedEntrance(
                      delay: 200,
                      child: _buildStatItem(
                        isChinese ? "活跃" : "Active",
                        '${user?.totalSignInDays ?? 0}',
                        isChinese ? "天" : "Days",
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _animatedEntrance(
                      delay: 300,
                      child: _buildStatItem(
                        isChinese ? "经验值" : "XP",
                        '${user?.xp ?? 0}',
                        isChinese ? "分" : "Points",
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _animatedEntrance(
                      delay: 350,
                      child: _buildStatItem(
                        isChinese ? "连续" : "Streak",
                        '${user?.streakDays ?? 0}',
                        isChinese ? "天" : "Days",
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _animatedEntrance(
                      delay: 400,
                      child: _buildStatItem(
                        isChinese ? "等级" : "Level",
                        '${user?.level ?? 1}',
                        isChinese ? "级" : "Rank",
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              _animatedEntrance(
                delay: 450,
                child: _buildMenuSection([
                  _menuItem(
                    context,
                    Icons.person_outline,
                    isChinese ? "账号安全" : "Account Security",
                    () => _navigateToSecurity(context),
                  ),
                  _menuItem(
                    context,
                    Icons.notifications_none,
                    isChinese ? "消息通知" : "Notifications",
                    () => _navigateToNotifications(context),
                  ),
                  _menuItem(
                    context,
                    Icons.language,
                    isChinese ? "语言设置" : "Language",
                    () => _navigateToLanguage(context),
                  ),
                ]),
              ),
              const SizedBox(height: 15),
              _animatedEntrance(
                delay: 500,
                child: _buildMenuSection([
                  _menuItem(
                    context,
                    Icons.workspace_premium,
                    isChinese ? "会员订阅" : "Premium Membership",
                    () => _navigateToPremium(context),
                    isPremium: true,
                  ),
                  _menuItem(
                    context,
                    Icons.help_outline,
                    isChinese ? "帮助与支持" : "Support & Help",
                    () => _navigateToSupport(context),
                  ),
                  _menuItem(
                    context,
                    Icons.info_outline,
                    isChinese ? "关于我们" : "About Us",
                    () => _navigateToAbout(context),
                  ),
                ]),
              ),
              const SizedBox(height: 20),
              _animatedEntrance(
                delay: 560,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Text(
                    isChinese ? "后端已连接" : "Connected backend: ${controller.baseUrl}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _animatedEntrance(
                delay: 620,
                child: TextButton(
                  onPressed: () => controller.logout(),
                  child: Text(
                    isChinese ? "退出登录" : "Log Out",
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToLanguage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LanguagePage(),
      ),
    );
    setState(() {});
  }

  void _navigateToSecurity(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SecurityPage(),
      ),
    );
  }

  void _navigateToNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationsPage(),
      ),
    );
  }

  void _navigateToPremium(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PremiumPage(),
      ),
    );
  }

  void _navigateToSupport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SupportPage(),
      ),
    );
  }

  void _navigateToAbout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AboutUsPage(),
      ),
    );
  }

  Widget _animatedEntrance({required Widget child, required int delay}) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: delay)),
      builder: (context, snapshot) {
        final isVisible = snapshot.connectionState == ConnectionState.done;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: isVisible ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
          builder: (context, value, childWidget) {
            return Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, 40 * (1 - value)),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
    );
  }

  Widget _menuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isPremium = false,
  }) {
    double scale = 1.0;
    return StatefulBuilder(
      builder: (context, setInternalState) {
        return GestureDetector(
          onTapDown: (_) => setInternalState(() => scale = 0.94),
          onTapUp: (_) => setInternalState(() => scale = 1.0),
          onTapCancel: () => setInternalState(() => scale = 1.0),
          onTap: onTap,
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 100),
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 24, color: darkCard),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: mainGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isChinese ? "会员" : "PRO",
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.black38,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileCard({
    required String userName,
    required String email,
    required int level,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: mainGreen,
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : 'T',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isChinese ? "等级 $level" : "Level $level",
                  style: TextStyle(
                    color: mainGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: mainGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(children: children),
    );
  }
}