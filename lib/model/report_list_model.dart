// To parse this JSON data, do
//
//     final reportListModel = reportListModelFromJson(jsonString);

import 'dart:convert';

ReportListModel reportListModelFromJson(String str) =>
    ReportListModel.fromJson(json.decode(str));

String reportListModelToJson(ReportListModel data) =>
    json.encode(data.toJson());

class ReportListModel {
  bool isSuccess;
  String message;
  Data data;

  ReportListModel({
    required this.isSuccess,
    required this.message,
    required this.data,
  });

  factory ReportListModel.fromJson(Map<String, dynamic> json) =>
      ReportListModel(
        isSuccess: json["isSuccess"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "isSuccess": isSuccess,
        "message": message,
        "data": data.toJson(),
      };
}

class Data {
  List<Card> cards;
  List<Detail> details;

  Data({
    required this.cards,
    required this.details,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        cards: List<Card>.from(json["cards"].map((x) => Card.fromJson(x))),
        details:
            List<Detail>.from(json["details"].map((x) => Detail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "cards": List<dynamic>.from(cards.map((x) => x.toJson())),
        "details": List<dynamic>.from(details.map((x) => x.toJson())),
      };
}

class Card {
  int requests;
  int pending;
  int reject;
  int bandig;
  int discount;
  int cardReturn;
  int approved;

  Card({
    required this.requests,
    required this.pending,
    required this.reject,
    required this.bandig,
    required this.discount,
    required this.cardReturn,
    required this.approved,
  });

  factory Card.fromJson(Map<String, dynamic> json) => Card(
        requests: json["requests"],
        pending: json["pending"],
        reject: json["reject"],
        bandig: json["bandig"],
        discount: json["discount"],
        cardReturn: json["returnCount"],
        approved: json["approved"],
      );

  Map<String, dynamic> toJson() => {
        "requests": requests,
        "pending": pending,
        "reject": reject,
        "bandig": bandig,
        "discount": discount,
        "returnCount": cardReturn,
        "approved": approved,
      };
}

class Detail {
  int requestId;
  String date;
  String vendorName;

  Detail({
    required this.requestId,
    required this.date,
    required this.vendorName,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        requestId: json["requestID"],
        date: json["date"],
        vendorName: json["vendorName"],
      );

  Map<String, dynamic> toJson() => {
        "requestID": requestId,
        "date": date,
        "vendorName": vendorName,
      };
}
