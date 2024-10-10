import 'dart:convert';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:marchandise/screens/model/Vendors.dart';
import 'package:marchandise/screens/model/product_and_categories_model.dart';
import 'package:marchandise/screens/model/vendor_and_salesperson_model.dart';
import 'package:marchandise/utils/constants.dart';
import 'package:marchandise/utils/urls.dart';

class MerchendiserApiService {
  // Fetch Vendors

  Future<List<Vendors>> fetchVendors(
      {String query = '', int page = 1, int pageSize = 20}) async {
    try {
      final response = await http.get(
        Uri.parse(Urls.getVendors),
        headers: {
          'PageNo': page.toString(),
          'PageSize': pageSize.toString(),
          'FilteText': query,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['isSuccess']) {
          return (data['data'] as List)
              .map((json) => Vendors.fromJson(json))
              .toList();
        } else {
          throw Exception('Failed to load vendors');
        }
      } else {
        throw Exception('Failed to load vendors');
      }
    } catch (e) {
      throw Exception('Failed to load vendors: $e');
    }
  }

  // Fetch Sales Persons

  Future<SalesPerson> fetchSalesPersons() async {
    final response = await http.get(
      Uri.parse(Urls.getSalesPersons),
    );
    if (response.statusCode == 200) {
      return SalesPerson.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load salespersons');
    }
  }

  Future<VendorAndSalesPersonModel> getVendorAndSalesPersonData(
      int? CustomerID) async {
    final apiUrl = Uri.parse(Urls.getSalesPersons);
    try {
      EasyLoading.show(
          status: 'Loading...',
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: false);

      Map<String, String> headers = {'CustomerID': '$CustomerID'};

      final response = await http.get(apiUrl, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print("Response:>>>$jsonResponse");
        final vendorAndSalesPersonModel =
            VendorAndSalesPersonModel.fromJson(jsonResponse);

        return vendorAndSalesPersonModel;
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<ProductAndCategoriesModel> getProductAndCategories({
    required int flag,
    required int pageNo,
    required int vendorId,
    required String filterText,
    List<int>? selectedCategoryIds,
  }) async {
    final apiUrl = Uri.parse(Urls.getProductAndCategories);

    String selectedCategories =
        selectedCategoryIds != null && selectedCategoryIds.isNotEmpty
            ? selectedCategoryIds.join(',')
            : '';

    Map<String, String> headers = {
      'flag': '$flag',
      'PageNo': '$pageNo',
      'PageSize': '200',
      'FilteText': '$filterText',
      'VendorId': '$vendorId',
      if (selectedCategories.isNotEmpty)
        'SelectedCategoryIds': selectedCategories,
    };

    try {
      EasyLoading.show();
      final response = await http.get(apiUrl, headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final productAndCategoreisModel =
            ProductAndCategoriesModel.fromJson(jsonResponse);

        return productAndCategoreisModel;
      } else {
        throw Exception("Failed fetch to data");
      }
    } catch (e) {
      throw Exception("An Error Occured: $e");
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<List<dynamic>> fetchAlternativeUnits(dynamic itemID) async {
    final Url = Uri.parse(Urls.getItemAlternativeUnit);
    final response =
        await http.get(Url, headers: {'itemID': itemID.toString()});
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['isSuccess']) {
        return responseData['data'];
      } else {
        throw Exception('Error: ${responseData['message']}');
      }
    } else {
      throw Exception('Failed to fetch data from API');
    }
  }

  void showPopupError(String message, context) {
    // Handle the error or unsuccessful response here, e.g., show a popup
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
