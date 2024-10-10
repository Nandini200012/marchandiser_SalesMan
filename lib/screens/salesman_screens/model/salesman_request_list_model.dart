// To parse this JSON data, do
//
//     final salesmanRequestListModel = salesmanRequestListModelFromJson(jsonString);

import 'dart:convert';

SalesmanRequestListModel salesmanRequestListModelFromJson(String str) =>
    SalesmanRequestListModel.fromJson(json.decode(str));

String salesmanRequestListModelToJson(SalesmanRequestListModel data) =>
    json.encode(data.toJson());

class SalesmanRequestListModel {
  bool isSuccess;
  String message;
  List<Datum> data;

  SalesmanRequestListModel({
    required this.isSuccess,
    required this.message,
    required this.data,
  });

  factory SalesmanRequestListModel.fromJson(Map<String, dynamic> json) =>
      SalesmanRequestListModel(
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
  String date;
  String vendorCode;

  Datum({
    required this.vendorName,
    required this.vendorId,
    required this.requestId,
    required this.totalProduct,
    required this.date,
    required this.vendorCode,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        vendorName: json["vendorName"],
        vendorId: json["vendorID"],
        requestId: json["requestID"],
        totalProduct: json["totalProduct"],
        date: json["date"],
        vendorCode: json["CustomerCode"],
      );

  Map<String, dynamic> toJson() => {
        "vendorName": vendorName,
        "vendorID": vendorId,
        "requestID": requestId,
        "totalProduct": totalProduct,
        "date": date,
        "CustomerCode": vendorCode,
      };
}
