import 'package:flutter/material.dart';

class Cart with ChangeNotifier {
  List<CartItem> items = [];

  void addItem(CartItem item) {
    items.add(item);
    notifyListeners();
  }
}

class CartItem {
  String name;
  int quantity;
  DateTime date;

  CartItem(this.name, this.quantity, this.date);
}
