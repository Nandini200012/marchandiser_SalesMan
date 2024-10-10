// To parse this JSON data, do
//
//     final requestListById = requestListByIdFromJson(jsonString);

import 'dart:convert';

RequestListById requestListByIdFromJson(String str) =>
    RequestListById.fromJson(json.decode(str));

String requestListByIdToJson(RequestListById data) =>
    json.encode(data.toJson());

class RequestListById {
  bool isSuccess;
  String message;
  List<Datum> data;

  RequestListById({
    required this.isSuccess,
    required this.message,
    required this.data,
  });

  factory RequestListById.fromJson(Map<String, dynamic> json) =>
      RequestListById(
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
  int prdouctId;
  String prdouctName;
  int siNo;
  int qty;
  String date;

  Datum({
    required this.prdouctId,
    required this.prdouctName,
    required this.siNo,
    required this.qty,
    required this.date,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        prdouctId: json["prdouctID"],
        prdouctName: json["prdouctName"],
        siNo: json["siNo"],
        qty: json["qty"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        "prdouctID": prdouctId,
        "prdouctName": prdouctName,
        "siNo": siNo,
        "qty": qty,
        "date": date,
      };
}
