import 'package:flutter/material.dart';

class ProductDetailsProvider with ChangeNotifier {
  dynamic? _productId;
  dynamic? _productName;
  dynamic? _UOM;
  dynamic? _UOMId;
  dynamic? _Cost;
  dynamic? _ItemId;

  dynamic? get productId => _productId;
  dynamic? get productName => _productName;
  dynamic? get UOM => _UOM;
  dynamic? get UOMId => _UOMId;
  dynamic? get Cost => _Cost;
  dynamic? get ItemId => _ItemId;

  setProductDetails(dynamic productId, dynamic productName, dynamic UOM,
      dynamic UOMId, dynamic Cost, dynamic ItemID) {
    _productId = productId;
    _productName = productName;
    _UOM = UOM;
    _UOMId = UOMId;
    _Cost = Cost;
    _ItemId = ItemID;

    notifyListeners();
  }

  clearProductDetails() {
    _productId = null;
    _productName = null;
    _UOM = null;
    _ItemId = null;
    _UOMId = null;
    _Cost = null;
    notifyListeners();
  }
}
