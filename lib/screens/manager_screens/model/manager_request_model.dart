// To parse this JSON data, do
//
//     final mangerRequestListModel = mangerRequestListModelFromJson(jsonString);

import 'dart:convert';

import 'package:marchandise/utils/dynamic_alert_box.dart';

MangerRequestListModel mangerRequestListModelFromJson(String str) =>
    MangerRequestListModel.fromJson(json.decode(str));

String mangerRequestListModelToJson(MangerRequestListModel data) =>
    json.encode(data.toJson());

class MangerRequestListModel {
  bool isSuccess;
  String message;
  List<Datum> data;

  MangerRequestListModel({
    required this.isSuccess,
    required this.message,
    required this.data,
  });

  factory MangerRequestListModel.fromJson(Map<String, dynamic> json) =>
      MangerRequestListModel(
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
  dynamic prdouctId;
  String prdouctName;
  dynamic prdouctSiNo;
  int requestId;
  String date;
  String salesPerson;
  double DiscPerc;
  bool isExpanded;
  dynamic uom;
  dynamic cost;
  dynamic qty;
  dynamic note;
  dynamic reason;
  dynamic itemID;
  String discountMode;
  double discountAmount;
  dynamic QtySplitSiNo;

  Datum({
    required this.vendorName,
    required this.vendorId,
    required this.prdouctId,
    required this.prdouctName,
    required this.prdouctSiNo,
    required this.requestId,
    required this.date,
    required this.salesPerson,
    required this.DiscPerc,
    this.isExpanded = false,
    required this.uom,
    required this.qty,
    required this.cost,
    required this.note,
    required this.reason,
    required this.itemID,
    required this.discountMode,
    required this.discountAmount,
    required this.QtySplitSiNo,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        vendorName: json["vendorName"],
        vendorId: json["vendorID"],
        prdouctName: json["prdouctName"],
        requestId: json["requestID"],
        date: json["date"],
        salesPerson: json["salesPerson"],
        DiscPerc: json["DiscPerc"].toDouble(),
        prdouctId: json['prdouctID'],
        prdouctSiNo: json['prdouctSINo'],
        uom: json['UOM'],
        qty: json['Qty'],
        cost: json['Cost'],
        note: json['Note'],
        reason: json['Reason'],
        itemID: json['itemID'],
        discountMode: json['discountMode'],
        discountAmount: json['discountAmount'].toDouble(),
        QtySplitSiNo: json['QtySplit_SINo'],
      );

  Map<String, dynamic> toJson() => {
        "vendorName": vendorName,
        "vendorID": vendorId,
        "prdouctID": prdouctId,
        "prdouctName": prdouctName,
        "prdouctSINo": prdouctSiNo,
        "requestID": requestId,
        "date": date,
        "salesPerson": salesPerson,
        "DiscPerc": DiscPerc,
        "UOM": uom,
        "Qty": qty,
        "Cost": cost,
        "Note": note,
        "itemID": itemID,
        "discountMode": discountMode,
        "discountAmount": discountAmount,
        "QtySplit_SINo": QtySplitSiNo,
      };
}
