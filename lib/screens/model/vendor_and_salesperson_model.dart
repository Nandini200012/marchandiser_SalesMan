import 'dart:convert';

VendorAndSalesPersonModel vendorAndSalesPersonModelFromJson(String str) =>
    VendorAndSalesPersonModel.fromJson(json.decode(str));

String vendorAndSalesPersonModelToJson(VendorAndSalesPersonModel data) =>
    json.encode(data.toJson());

class VendorAndSalesPersonModel {
  bool isSuccess;
  String message;
  Data data;

  VendorAndSalesPersonModel({
    required this.isSuccess,
    required this.message,
    required this.data,
  });

  factory VendorAndSalesPersonModel.fromJson(Map<String, dynamic> json) =>
      VendorAndSalesPersonModel(
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
  List<SalesPerson> salesPersons;

  Data({
    required this.salesPersons,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        salesPersons: List<SalesPerson>.from(
            json["salesPersons"].map((x) => SalesPerson.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "salesPersons": List<dynamic>.from(salesPersons.map((x) => x.toJson())),
      };
}

class SalesPerson {
  int salesPerson;
  String salesPersonName;

  SalesPerson({
    required this.salesPerson,
    required this.salesPersonName,
  });

  factory SalesPerson.fromJson(Map<String, dynamic> json) => SalesPerson(
        salesPerson: json["salesPerson"],
        salesPersonName: json["salesPersonName"],
      );

  Map<String, dynamic> toJson() => {
        "salesPerson": salesPerson,
        "salesPersonName": salesPersonName,
      };
}
