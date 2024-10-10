import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:marchandise/screens/model/login_model.dart';


// for login
Future<Login> loginUser(
  String companyName,
  String usercode,
  String password,

) async {
 
  final String apiUrl = 'https:/api/login';

  final Map<String, String> bodyParams = {
    "TenantName": companyName,
    "usercode": usercode,
    "password": password,
  };

  try {
    EasyLoading.show();
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(bodyParams),
    );

    if (response.statusCode == 200) {
      return loginFromJson(response.body);
    } else {
      throw Exception('Failed to login');
    }
  } catch (e) {
    print('Exception during login: $e');
    rethrow; 
  } finally {
    EasyLoading.dismiss();
  }
}

// for RefreshLogin
Future<Login> refreshLogin(String accessToken, String refreshToken) async {
  final String apiUrl =
      '/api/refreshLogin'; 

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        '_accessToken': accessToken,
        'refreshToken': refreshToken
      },
   
    );

    if (response.statusCode == 200) {
      return loginFromJson(response.body);
    } else {
      throw Exception('Failed to refresh login');
    }
  } catch (e) {
    print('Exception during login refresh: $e');
    rethrow; 
  }
}
