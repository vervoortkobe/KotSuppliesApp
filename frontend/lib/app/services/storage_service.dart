import 'package:shared_preferences/shared_preferences.dart';
import 'package:kotsupplies/app/models/user.dart';

class StorageService {
  static const String _userGuidKey = 'user_guid';
  static const String _usernameKey = 'user_username';
  static const String _profileImageGuidKey = 'user_profile_image_guid';
  static const String _listGuidsKey = 'user_list_guids';

  Future<void> saveLoggedInUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userGuidKey, user.guid);
    await prefs.setString(_usernameKey, user.username);
    if (user.profileImageGuid != null) {
      await prefs.setString(_profileImageGuidKey, user.profileImageGuid!);
    } else {
      await prefs.remove(_profileImageGuidKey);
    }
  }

  Future<User?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final guid = prefs.getString(_userGuidKey);
    final username = prefs.getString(_usernameKey);
    final profileImageGuid = prefs.getString(_profileImageGuidKey);

    if (guid != null && username != null) {
      return User(
        guid: guid,
        username: username,
        profileImageGuid: profileImageGuid,
      );
    }
    return null;
  }

  Future<void> clearLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userGuidKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_profileImageGuidKey);
    await prefs.remove(_listGuidsKey);
  }
}
