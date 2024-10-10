// To parse this JSON data, do
//
//     final salesManDetailsInfoModel = salesManDetailsInfoModelFromJson(jsonString);

import 'dart:convert';

SalesManDetailsInfoModel salesManDetailsInfoModelFromJson(String str) =>
    SalesManDetailsInfoModel.fromJson(json.decode(str));

String salesManDetailsInfoModelToJson(SalesManDetailsInfoModel data) =>
    json.encode(data.toJson());

class SalesManDetailsInfoModel {
  bool isSuccess;
  String message;
  List<Datum> data;

  SalesManDetailsInfoModel({
    required this.isSuccess,
    required this.message,
    required this.data,
  });

  factory SalesManDetailsInfoModel.fromJson(Map<String, dynamic> json) =>
      SalesManDetailsInfoModel(
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
  num qty;
  dynamic date;
  dynamic reason;
  dynamic note;

  Datum({
    required this.qty,
    required this.date,
    required this.reason,
    required this.note,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        qty: json["qty"],
        date: json["date"],
        reason: json["reason"],
        note: json["note"],
      );

  Map<String, dynamic> toJson() => {
        "qty": qty,
        "date": date,
        "reason": reason,
        "note": note,
      };
}
