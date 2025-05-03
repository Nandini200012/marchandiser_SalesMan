// To parse this JSON data, do
//
//     final commentModel = commentModelFromJson(jsonString);

import 'dart:convert';

CommentModel commentModelFromJson(String str) =>
    CommentModel.fromJson(json.decode(str));

String commentModelToJson(CommentModel data) => json.encode(data.toJson());

class CommentModel {
  bool isSuccess;
  String message;
  List<CommentData> data;

  CommentModel({
    required this.isSuccess,
    required this.message,
    required this.data,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        isSuccess: json["isSuccess"],
        message: json["message"],
        data: List<CommentData>.from(
            json["data"].map((x) => CommentData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "isSuccess": isSuccess,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class CommentData {
  int commentId;
  int requestId;
  String userId;
  int productId;
  String productName;
  String comments;
  DateTime createdDateTime;

  CommentData({
    required this.commentId,
    required this.requestId,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.comments,
    required this.createdDateTime,
  });

  factory CommentData.fromJson(Map<String, dynamic> json) => CommentData(
        commentId: json["CommentID"],
        requestId: json["RequestID"],
        userId: json["UserID"],
        productId: json["ProductID"],
        productName: json["ProductName"],
        comments: json["Comments"],
        createdDateTime: DateTime.parse(json["CreatedDateTime"]),
      );

  Map<String, dynamic> toJson() => {
        "CommentID": commentId,
        "RequestID": requestId,
        "UserID": userId,
        "ProductID": productId,
        "ProductName": productName,
        "Comments": comments,
        "CreatedDateTime": createdDateTime.toIso8601String(),
      };
}
