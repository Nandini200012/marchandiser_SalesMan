import 'package:flutter/material.dart';
import 'package:marchandise/model/cart_model.dart';
import 'package:marchandise/screens/marchandiser_screens/cart_details_screen.dart';

class CartProvider extends ChangeNotifier {
  List<CartDetailsItem> _itemList = [];
  List<CartDetailsItem> get items => _itemList;
  Item? cartItem;

  void addToCart(CartDetailsItem newList) {
    _itemList.add(newList);
    notifyListeners();
  }

  void setCartItem(Item newItem) {
    cartItem = newItem;
    notifyListeners();
  }

  int getCartQuantity() {
    int totalQuantity = 0;
    for (var item in _itemList) {
      totalQuantity += item.quantity;
    }
    return totalQuantity;
  }

  void removeFromCart(CartDetailsItem item) {
    _itemList.remove(item);
    notifyListeners();
  }

    // Add this method to clear the entire cart
  void clearCart() {
    _itemList.clear();
    notifyListeners();
  }

    // Add this method to get the total quantity of all products in the cart
  int getTotalProduct(CartDetailsItem  product) {
    int totalProduct = 0;
    for (var product in _itemList) {
      totalProduct += product.quantity ;
    }
    return totalProduct;
  }
}
