import 'dart:convert';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:marchandise/screens/salesman_screens/model/salesman_info_model.dart';
import 'package:marchandise/screens/salesman_screens/model/salesman_request_by_id_model.dart';
import 'package:marchandise/screens/salesman_screens/model/salesman_request_list_model.dart';
import 'package:marchandise/utils/constants.dart';
import 'package:marchandise/utils/urls.dart';
import 'package:http/http.dart' as http;

class SalesManApiService {
  Future<SalesmanRequestListModel> getSalesmanRequestList() async {
    final apiUrl = Uri.parse(Urls.salesManRequestList);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      "PageNo": "1",
      "flag": "111"
    };

    try {
      EasyLoading.show(
          status: 'Loading...',
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: false);
      final response = await http.get(apiUrl, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print("Response:>>>$jsonResponse");
        final salesmanRequestList =
            SalesmanRequestListModel.fromJson(jsonResponse);

        return salesmanRequestList;
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<SalesmanRequestById> getSalesManRequestById(int requestId) async {
    final apiUrl = Uri.parse(Urls.salesManRequestById);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      "flag": "112",
      "RequestID": requestId.toString()
    };

    try {
      EasyLoading.show(
          status: 'Loading...',
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: false);
      final response = await http.get(apiUrl, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print("Response:>>>$jsonResponse");
        final salesManRequestById = SalesmanRequestById.fromJson(jsonResponse);

        return salesManRequestById;
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<SalesManDetailsInfoModel> getSalesManRequestByIdInfo(
      int requestId, dynamic productId) async {
    final apiUrl = Uri.parse(Urls.requestListByProductInfo);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      "flag": "116",
      "RequestID": requestId.toString(),
      "ProductId": productId.toString()
    };

    try {
      EasyLoading.show(
          status: 'Loading...',
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: false);
      final response = await http.get(apiUrl, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print("Response:>>>$jsonResponse");
        final salesManDetailsInfo =
            SalesManDetailsInfoModel.fromJson(jsonResponse);

        return salesManDetailsInfo;
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }
}
