import 'package:flutter/material.dart';

class CreateRequestVendorDetailsProvider with ChangeNotifier {
  int? _vendorId;
  String? _vendorName;
  int? _salesPerson;
  String? _salesPersonName;

  int? get vendorId => _vendorId;
  String? get vendorName => _vendorName;
  int? get salesPerson => _salesPerson;
  String? get salesPersonName => _salesPersonName;

  void setVendorDetails(int vendorId, String vendorName, int salesPerson,
      String salesPersonName) {
    _vendorId = vendorId;
    _vendorName = vendorName;
    _salesPerson = salesPerson;
    _salesPersonName = salesPersonName;
    notifyListeners();
  }

  void clearVendorDetails() {
    _vendorId = null;
    _vendorName = null;
    _salesPerson = null;
    _salesPersonName = null;
    notifyListeners();
  }
}
