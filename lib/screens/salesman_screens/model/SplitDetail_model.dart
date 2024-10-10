// import 'package:marchandise/screens/salesman_screens/model/discount_mode.dart';

import 'discount_mode.dart';

class SplitDetail {
  final int splitQty;
  final String splitStatus;
  final double discountValue;
  final DiscountMode discountMode;
  final double discountAmount;
  final double discountPercentage;
  final dynamic productId; // Add product ID

  SplitDetail(
      this.productId, // Include product ID in constructor
      this.splitQty,
      this.splitStatus, {
        required this.discountValue,
        required this.discountMode,
        required this.discountAmount,
        required this.discountPercentage,
      });

  // Add this method
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'splitQty': splitQty,
      'splitStatus': splitStatus,
      'discountValue': discountValue,
      'discountMode': discountMode.toString().split('.').last,
      'discountAmount': discountAmount,
      'discountPercentage': discountPercentage,
    };
  }
}
