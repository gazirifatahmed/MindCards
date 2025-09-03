import 'package:shared_preferences/shared_preferences.dart';

enum SavedKey { content, mode, count }

class AppStorage {
  static const _kContent = 'last_content';
  static const _kMode = 'last_mode'; // 'flashcards' or 'cloze'
  static const _kCount = 'last_count';

  static Future<void> saveContent(String content) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kContent, content);
  }

  static Future<String?> loadContent() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kContent);
  }

  static Future<void> saveMode(String mode) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kMode, mode);
  }

  static Future<String?> loadMode() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kMode);
  }

  static Future<void> saveCount(int count) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kCount, count);
  }

  static Future<int?> loadCount() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getInt(_kCount);
  }
}
