import 'package:flutter/material.dart';
import 'package:marchandise/model/cart_details_model.dart';
import 'package:marchandise/model/cart_model.dart';
import 'package:marchandise/screens/marchandiser_screens/cart_details_screen.dart';

class ShopList extends ChangeNotifier {
  static final List<Item> _items = [
    Item(name: 'Apple', productId: 12345, count: 0),
    Item(name: 'Shampo', productId: 02458, count: 0),
    Item(name: 'Banana', productId: 78945, count: 0),
    Item(name: 'Hair Oil', productId: 25416, count: 0),
  ];
  List<Item> _cartItem = [];
  int _cartCount = 0;
  List<CartDetailsItem> itemList = [];

  //provide all getters
  List<Item> get items => _items;
  List<Item> get cartItems => _cartItem;
  int get itemCount => _items.length;
  int get cartItemCount => _cartItem.length;
  int get cartCount => _cartCount <= 0 ? 0 : _cartCount;

  //add item to cart
  void addToCart(Item item) {
    if (_cartItem.contains(item)) {
      _cartItem[_cartItem.indexOf(item)].count++;
    } else {
      _cartItem.add(item);
      _cartItem[(_cartItem.indexOf(item))].count = 1;
      _items[_items.indexOf(item)].count = 1;
    }
    _cartCount++;
    notifyListeners();
  }

  //removing item from cart
  void removeFromCart(Item item) {
    if (_cartItem[_cartItem.indexOf(item)].count == 1) {
      _items[_items.indexOf(item)].count = 0;
      _cartItem.remove(item);
    } else {
      _cartItem[_cartItem.indexOf(item)].count--;
    }
    _cartCount--; // Decrement cart count in both cases
    notifyListeners();
  }

  // Remove item from cart at a specific index
  void removeCartItemAtIndex(int index) {
    if (index >= 0 && index < _cartItem.length) {
      Item removedItem = _cartItem.removeAt(index);
      _items[_items.indexOf(removedItem)].count = 0;
      _cartCount--;
      notifyListeners();
    }
  }

  // void addItemToList(String productName,String productIndex, int quantity, DateTime selectedDate ,String note,String reason) {
  //   CartDetailsItem newItem = CartDetailsItem(productName,productIndex,  quantity, selectedDate,note,reason);
  //   itemList.add(newItem);
  //   notifyListeners();
  // }
}
