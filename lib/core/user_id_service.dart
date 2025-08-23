import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Setters
  static Future<bool> setString(String key, String value) async {
    await init();
    return _prefs!.setString(key, value);
  }

  static Future<bool> setBool(String key, bool value) async {
    await init();
    return _prefs!.setBool(key, value);
  }

  static Future<bool> setInt(String key, int value) async {
    await init();
    return _prefs!.setInt(key, value);
  }

  static Future<bool> setDouble(String key, double value) async {
    await init();
    return _prefs!.setDouble(key, value);
  }

  // Getters
  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  static Future<int?> getInt(String key) async {
    await init();
    return _prefs?.getInt(key);
  }

  static double? getDouble(String key) {
    return _prefs?.getDouble(key);
  }

  // Remove a key
  static Future<bool> remove(String key) async {
    await init();
    return _prefs!.remove(key);
  }

  // Clear all preferences
  static Future<bool> clear() async {
    await init();
    return _prefs!.clear();
  }
}
