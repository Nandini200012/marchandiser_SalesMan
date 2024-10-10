import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtil {
  static Future<void> setUserDetails(
      String userId, int employeeId, String appRole) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('UserID', userId);
    await prefs.setInt('EmployeeId', employeeId);
    await prefs.setString('AppRole', appRole);
  }

  static Future<Map<String, dynamic>?> getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('UserID');
    int? employeeId = prefs.getInt('EmployeeId');
    String? appRole = prefs.getString('AppRole');

    if (userId != null && employeeId != null && appRole != null) {
      return {
        'UserID': userId,
        'EmployeeId': employeeId,
        'AppRole': appRole,
      };
    } else {
      return null;
    }
  }

  static Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('UserID');
  }

  static Future<dynamic?> getLoggedEmployeeID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('EmployeeId');
  }

  static Future<void> clearUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('UserID');
    await prefs.remove('EmployeeId');
    await prefs.remove('AppRole');
  }
}
