// To parse this JSON data, do
//
//     final salesmanRequestById = salesmanRequestByIdFromJson(jsonString);

import 'dart:convert';

SalesmanRequestById salesmanRequestByIdFromJson(String str) =>
    SalesmanRequestById.fromJson(json.decode(str));

String salesmanRequestByIdToJson(SalesmanRequestById data) =>
    json.encode(data.toJson());

class SalesmanRequestById {
  bool isSuccess;
  String message;
  List<Datum> data;

  SalesmanRequestById({
    required this.isSuccess,
    required this.message,
    required this.data,
  });

  factory SalesmanRequestById.fromJson(Map<String, dynamic> json) =>
      SalesmanRequestById(
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
  dynamic prdouctId;
  String prdouctName;
  int siNo;
  int qty;
  dynamic date;
  String status;
  dynamic uom;
  dynamic cost;
  String reason;
  String notes;
  dynamic itemID;
  dynamic uomID;

  Datum({
    required this.prdouctId,
    required this.prdouctName,
    required this.siNo,
    required this.qty,
    required this.date,
    required this.status,
    required this.uom,
    required this.cost,
    required this.reason,
    required this.notes,
    required this.itemID,
    required this.uomID,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        prdouctId: json["prdouctID"],
        prdouctName: json["prdouctName"],
        siNo: json["siNo"],
        qty: json["qty"],
        date: json["date"],
        status: json["status"],
        uom: json["UOM"],
        cost: json["Cost"],
        reason: json["reason"] ?? "N/A",
        notes: json["notes"] ?? "N/A",
        itemID: json["itemID"],
        uomID: json["uomID"] ?? "0",
      );

  Map<String, dynamic> toJson() => {
        "prdouctID": prdouctId,
        "prdouctName": prdouctName,
        "siNo": siNo,
        "qty": qty,
        "date": date,
        "status": status,
        "UOM": uom,
        "Cost": cost,
        "reason": reason ?? "N/A",
        "notes": notes ?? "N/A",
        "itemID": itemID,
        "uomID": uomID ?? "0",
      };
}
