import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:marchandise/model/excel_model.dart';

Future<ExportModel?> fetchExportData(
    {required String fromDate, required String toDate}) async {
  final uri =
      Uri.parse('https://marchandising.azurewebsites.net/api/exportExcel');

  final response = await http.get(
    uri,
    headers: {
      'accept': '*/*',
      'fromDate': fromDate,
      'toDate': toDate,
      'ReportListMode': 'salesman',
    },
  );
  print('header: from: $fromDate.$toDate');
  if (response.statusCode == 200) {
    try {
      final jsonData = json.decode(response.body);
      print('export data: ${response.body}');
      return ExportModel.fromJson(jsonData);
    } catch (e) {
      print('JSON parsing error: $e');
      return null;
    }
  } else {
    print('Failed to fetch data: ${response.statusCode}');
    return null;
  }
}
