import 'package:flutter/material.dart';
import 'home_page_content.dart'; // 你的主页文件

bool isChinese = false;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Georgia'),
      // 🔥 直接进你漂亮的主页！
      home: const HomePageContent(
        onGoToTask: _dummyTap,
        onGoToAward: _dummyTap,
      ),
    );
  }

  // 空方法，避免报错
  static void _dummyTap() {}
}