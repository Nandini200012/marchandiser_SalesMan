import 'dart:convert';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:marchandise/model/report_list_model.dart';
import 'package:marchandise/screens/manager_screens/model/manager_request_model.dart';
import 'package:marchandise/screens/manager_screens/model/report_details_list_model.dart';
import 'package:marchandise/utils/constants.dart';
import 'package:marchandise/utils/urls.dart';

class ManagerApiService {
  Future<MangerRequestListModel> managerRequestListByDiscount({
    required int pageNo,
    required String filterMode,
    required int flag,
    int? salesPersonID,
    int? vendorID,
  }) async {
    final apiUrl = Uri.parse(Urls.managerRequestList);

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      "flag": flag.toString(),
      "PageNo": pageNo.toString(),
      "FilterMode": filterMode
    };

    if (salesPersonID != null) {
      headers["SalesPersonID"] = salesPersonID.toString();
    }

    if (vendorID != null) {
      headers["VendorId"] = vendorID.toString();
    }

    try {
      EasyLoading.show(
          status: 'Loading...',
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: false);
      final response = await http.get(apiUrl, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print("Response:>>>$jsonResponse");
        final managerRequestList =
            MangerRequestListModel.fromJson(jsonResponse);

        return managerRequestList;
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  ///Report List
  Future<ReportListModel> getReportList({
    required String fromDate,
    required String toDate,
    required String reportListMode,
    required String filterMode,
    required int pageNo,
  }) async {
    final apiUrl = Uri.parse(Urls.reporList);

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': Constants.token,
      "fromDate": fromDate.toString(),
      "toDate": toDate.toString(),
      "ReportListMode": reportListMode.toString(),
      "FilterMode": filterMode.toString(),
      "PageNo": pageNo.toString(),
    };
    print("Print Header:$headers");
    try {
      EasyLoading.show(
          status: 'Loading...',
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: false);
      final response = await http.get(apiUrl, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print("Response:>>>$jsonResponse");
        final reportList = ReportListModel.fromJson(jsonResponse);
        return reportList;
      } else {
        final jsonResponse1 = json.decode(response.body);
        print("Print Header:$jsonResponse1");
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  //report List Details
  Future<ReportDetailsListModel> fetchReportDetailsList({
    required String reportListMode,
    required String filterMode,
    required int requestID,
  }) async {
    const url = Urls.reporListDetails;

    final headers = {
      'ReportListMode': reportListMode,
      'FilterMode': filterMode,
      'RequestID': requestID.toString(),
    };
    print("Request Details Headers :>>>$headers");

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      print("Response:>>> ${response.body}");
      return reportDetailsListModelFromJson(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
}
