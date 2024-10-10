import 'package:flutter/material.dart';
import 'package:marchandise/screens/salesman_screens/model/discount_mode.dart';

class SplitDetail {
  final dynamic productId;
  final dynamic productSINo;
  final int splitQty;
  final String splitStatus;
  final double discountValue;
  final DiscountMode discountMode;
  final double discountAmount;
  final double discountPercentage;

  SplitDetail(
      this.productId,
      this.productSINo,
      this.splitQty,
      this.splitStatus, {
        required this.discountValue,
        required this.discountMode,
        required this.discountAmount,
        required this.discountPercentage,
      });

  Map<String, dynamic> toMap() {
    return {
      'ItemID': productId,
      'QtySplit_ItemSINo': productSINo,
      'Qty': splitQty,
      'DiscountMode': discountMode.toString().split('.').last,
      'DiscountAmount': discountAmount,
      'DiscountPercentage': discountPercentage,
      'IsDiscount': splitStatus == 'Discount' ? true : false,
      'IsBanding': splitStatus == 'Banding' ? true : false,
      'IsReturn': splitStatus == 'Return' ? true : false,
      'IsApproved': null,
      'IsRejected': null,
    };
  }
}

class SplitProvider with ChangeNotifier {
  Map<String, List<SplitDetail>> _splitDetails = {};

  Map<String, List<SplitDetail>> get splitDetails => _splitDetails;

  void addSplitDetail(dynamic productId, dynamic productSINo, SplitDetail detail) {
    var key = '$productId-$productSINo';
    if (_splitDetails.containsKey(key)) {
      _splitDetails[key]!.add(detail);
    } else {
      _splitDetails[key] = [detail];
    }
    notifyListeners();
  }

  void removeSplitDetail(dynamic productId, dynamic productSINo, int index) {
    var key = '$productId-$productSINo';
    if (_splitDetails.containsKey(key)) {
      _splitDetails[key]!.removeAt(index);
      if (_splitDetails[key]!.isEmpty) {
        _splitDetails.remove(key);
      }
    }
    notifyListeners();
  }

  void clearSplitDetails(dynamic productId, dynamic productSINo) {
    var key = '$productId-$productSINo';
    _splitDetails.remove(key);
    notifyListeners();
  }

  void updateSplitDetails(dynamic productId, dynamic productSINo, List<SplitDetail> details) {
    var key = '$productId-$productSINo';
    _splitDetails[key] = details;
    notifyListeners();
  }

  List<SplitDetail>? getSplitDetails(dynamic productId, dynamic productSINo) {
    var key = '$productId-$productSINo';
    return _splitDetails[key];
  }

  void clearAllSplitDetails() {
    _splitDetails.clear();
    notifyListeners();
  }
}
