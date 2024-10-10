import 'package:flutter/material.dart';

class SalesPersonDetailsProvider with ChangeNotifier {
  String? _salesManName;
  int? _salesManId;
  String? _remarks;

  String? get salesManName => _salesManName;
  int? get salesManId => _salesManId;
  String? get remarks => _remarks;

  setSalesPersonDetails(String salesManName, int salesManId, String remarks) {
    _salesManName = salesManName;
    _salesManId = salesManId;
    _remarks = remarks;
    notifyListeners();
  }

  clearSalesPersonDetails() {
    _salesManName = null;
    _salesManId = null;
    _remarks = null;
    notifyListeners();
  }
}
