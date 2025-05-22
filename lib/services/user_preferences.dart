import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _firebaseProjectKey = 'firebase_project';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _isAnonymousKey = 'is_anonymous';

  static Future<void> setFirebaseProject(String projectName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_firebaseProjectKey, projectName);
  }

  static Future<String?> getFirebaseProject() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_firebaseProjectKey);
  }

  static Future<void> setUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userData['userId']);
    if (userData['email'] != null) {
      await prefs.setString(_userEmailKey, userData['email']);
    }
    await prefs.setBool(_isAnonymousKey, userData['isAnonymous']);
  }

  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString(_userIdKey),
      'email': prefs.getString(_userEmailKey),
      'isAnonymous': prefs.getBool(_isAnonymousKey) ?? false,
    };
  }

  static Future<void> clearFirebaseProject() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_firebaseProjectKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_isAnonymousKey);
  }
} 