import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> addComment(
  BuildContext context,
  int requestID,
  int productID,
  String productName,
  String comment,
) async {
  final url =
      Uri.parse('https://marchandising.azurewebsites.net/api/addComment');

  final headers = {
    'accept': '*/*',
    'Content-Type': 'application/json',
  };

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString("rememberedUsername");
  String? userId = prefs.getString('UserID');
  log('Request username: $username');
  log('Request userId: $userId');
  final body = jsonEncode({
    "requestID": requestID,
    "userID": userId ?? 'null',
    "productID": productID,
    // "userName": username ?? 'Unknown',
    "productName": productName,
    "comments": comment
  });

  log('Request Headers: $headers');
  log('Request Body: $body');

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comment added successfully!')),
      );
      log('Response: ${response.body}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment')),
      );
      log('Error: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    log('Exception: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $e')),
    );
  }
}
