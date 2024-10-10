import 'package:flutter/material.dart';

class SalesManRequestProvider extends ChangeNotifier {
  String? _productName;
  String? _productId;
  String? _productQuantity;

  String? get productName => _productName;
  String? get productId => _productId;
  String? get productQuantity => _productQuantity;

  setProductDetails(
      String productName, String ProductId, String productQuantity) {
    _productName = productName;
    _productId = productId;
    _productQuantity = productQuantity;
    notifyListeners();
  }

  clearProductDetails() {
    _productName = null;
    _productId = null;
    _productQuantity = null;
    notifyListeners();
  }
}
