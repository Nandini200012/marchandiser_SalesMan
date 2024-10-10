import 'package:flutter/material.dart';

import '../screens/salesman_screens/request_details_screen.dart';

class SelectionProvider extends ChangeNotifier {
  Set<Product> selectedProducts = {};

  void toggleSelection(Product product) {
    if (selectedProducts.contains(product)) {
      selectedProducts.remove(product);
    } else {
      selectedProducts.add(product);
    }
    notifyListeners();
  }
  void updateStatusAndClearSelection(String status) {
    // Perform the status update logic here...

    // Clear the selection after updating the status
    clearSelection();
  }

  void clearSelection() {
    selectedProducts.clear();
    notifyListeners();
  }
}
