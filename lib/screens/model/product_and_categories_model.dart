//import 'dart:ffi';

class ProductAndCategoriesModel {
  bool isSuccess;
  String message;
  Data data;

  ProductAndCategoriesModel({
    required this.isSuccess,
    required this.message,
    required this.data,
  });

  factory ProductAndCategoriesModel.fromJson(Map<String, dynamic> json) =>
      ProductAndCategoriesModel(
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
  List<Product> products;
  List<Category> categories;

  Data({
    required this.products,
    required this.categories,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        products: List<Product>.from(
            json["products"].map((x) => Product.fromJson(x))),
        categories: List<Category>.from(
            json["categories"].map((x) => Category.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
        "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
      };
}

class Category {
  int grpId;
  String grpName;

  Category({
    required this.grpId,
    required this.grpName,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        grpId: json["grpId"],
        grpName: json["grpName"],
      );

  Map<String, dynamic> toJson() => {
        "grpId": grpId,
        "grpName": grpName,
      };
}

class Product {
  String productId;
  String productName;
  dynamic UOM;
  dynamic UOMId;
  dynamic ProductCost;
  dynamic itemID;

  Product({
    required this.productId,
    required this.productName,
    required this.UOM,
    required this.UOMId,
    required this.ProductCost,
    required this.itemID,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
      productId: json["productId"],
      productName: json["productName"],
      UOM: json["UOM"],
      UOMId: json["UOMId"],
      ProductCost: json["Cost"],
      itemID: json["ItemID"]);

  Map<String, dynamic> toJson() => {
        "productId": productId,
        "productName": productName,
        "UOM": UOM,
        "UOMId": UOMId,
        "Cost": ProductCost,
        "ItemID": itemID,
      };
}
