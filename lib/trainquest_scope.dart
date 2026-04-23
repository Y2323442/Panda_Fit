import 'package:flutter/widgets.dart';

class TrainQuestScope extends InheritedWidget {
  const TrainQuestScope({
    super.key,
    required Widget child,
  }) : super(child: child);

  static AppController of(BuildContext context) {
    return AppController();
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}

class AppController {
  // 空的，不做任何事
}