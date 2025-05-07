// To parse this JSON data, do
//
//     final exportModel = exportModelFromJson(jsonString);

import 'dart:convert';

ExportModel exportModelFromJson(String str) =>
    ExportModel.fromJson(json.decode(str));

String exportModelToJson(ExportModel data) => json.encode(data.toJson());

class ExportModel {
  bool isSuccess;
  String message;
  List<ExportData> data;

  ExportModel({
    required this.isSuccess,
    required this.message,
    required this.data,
  });

  factory ExportModel.fromJson(Map<String, dynamic> json) => ExportModel(
        isSuccess: json["isSuccess"],
        message: json["message"],
        data: List<ExportData>.from(
            json["data"].map((x) => ExportData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "isSuccess": isSuccess,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class ExportData {
  String? prdouctId;
  String? prdouctName;
  int? quantity;
  String? expiryDate;
  String? note;
  String? reason;
  String? reqStatus;
  String? uom;
  double? cost;
  String? discMode;
  int? discPerc;
  double? discAmount;
  String? salesManActionDateTime;

  ExportData({
    this.prdouctId,
    this.prdouctName,
    this.quantity,
    this.expiryDate,
    this.note,
    this.reason,
    this.reqStatus,
    this.uom,
    this.cost,
    this.discMode,
    this.discPerc,
    this.discAmount,
    this.salesManActionDateTime,
  });

  factory ExportData.fromJson(Map<String, dynamic> json) => ExportData(
        prdouctId: json["prdouctID"] ?? "",
        prdouctName: json["prdouctName"] ?? "",
        quantity: json["quantity"] ?? 0,
        expiryDate: json["expiryDate"] ?? "",
        note: json["note"] ?? "",
        reason: json["reason"] ?? "",
        reqStatus: json["reqStatus"] ?? "",
        uom: json["UOM"] ?? "",
        cost: json["Cost"] != null ? json["Cost"].toDouble() : 0.0,
        discMode: json["DiscMode"] ?? "",
        discPerc: json["DiscPerc"] ?? 0,
        discAmount:
            json["DiscAmount"] != null ? json["DiscAmount"].toDouble() : 0.0,
        salesManActionDateTime: json["salesManActionDateTime"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "prdouctID": prdouctId,
        "prdouctName": prdouctName,
        "quantity": quantity,
        "expiryDate": expiryDate,
        "note": note,
        "reason": reason,
        "reqStatus": reqStatus,
        "UOM": uom,
        "Cost": cost,
        "DiscMode": discMode,
        "DiscPerc": discPerc,
        "DiscAmount": discAmount,
        "salesManActionDateTime": salesManActionDateTime,
      };
}
