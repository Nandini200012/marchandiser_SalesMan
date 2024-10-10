// To parse this JSON data, do
//
//     final salesManRequest = salesManRequestFromJson(jsonString);

import 'dart:convert';

SalesManRequest salesManRequestFromJson(String str) =>
    SalesManRequest.fromJson(json.decode(str));

String salesManRequestToJson(SalesManRequest data) =>
    json.encode(data.toJson());

class SalesManRequest {
  bool isSuccess;
  String message;
  List<Datum> data;

  SalesManRequest({
    required this.isSuccess,
    required this.message,
    required this.data,
  });

  factory SalesManRequest.fromJson(Map<String, dynamic> json) =>
      SalesManRequest(
        isSuccess: json["isSuccess"],
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "isSuccess": isSuccess,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  String vendorName;
  int vendorId;
  int requestId;
  int totalProduct;

  Datum({
    required this.vendorName,
    required this.vendorId,
    required this.requestId,
    required this.totalProduct,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        vendorName: json["vendorName"],
        vendorId: json["vendorID"],
        requestId: json["requestID"],
        totalProduct: json["totalProduct"],
      );

  Map<String, dynamic> toJson() => {
        "vendorName": vendorName,
        "vendorID": vendorId,
        "requestID": requestId,
        "totalProduct": totalProduct,
      };
}


// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class ApiService {
//   static Future<SalesManRequest> fetchDataFromApi(String apiUrl) async {
//     try {
//       final response = await http.get(Uri.parse(apiUrl));

//       if (response.statusCode == 200) {
//         // If the server returns a 200 OK response, parse the JSON
//         return salesManRequestFromJson(response.body);
//       } else {
//         // If the server did not return a 200 OK response,
//         // throw an exception.
//         throw Exception('Failed to load data');
//       }
//     } catch (e) {
//       // Handle network errors or other exceptions
//       throw Exception('Failed to load data: $e');
//     }
//   }
// }

// void main() async {
//   String apiUrl =
//       'https://example.com/api/data'; // Replace with your actual API URL
//   try {
//     SalesManRequest result = await ApiService.fetchDataFromApi(apiUrl);
//     print('API call successful: ${result.message}');
//     // Do something with the result
//   } catch (e) {
//     print('Error during API call: $e');
//     // Handle error
//   }
// }

