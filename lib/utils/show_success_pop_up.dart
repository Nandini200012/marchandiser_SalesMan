import 'package:flutter/material.dart';
import 'package:marchandise/screens/salesman_screens/salesman_bottom_navbar.dart';

class ShowSuccessPopUp {
  void successPopup(
      {required BuildContext context,required String title}) {
    if (Navigator.canPop(context)) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title:  Center(
              child: Text(title),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10.0), // Adjust the value as needed
                            side: const BorderSide(
                                color: Colors
                                    .blue), // Change the color to the desired outline color
                          ),
                        ),
                      ),
                      onPressed: () {
                  
                        Navigator.of(context).pop();
                             Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const SalesManBottomNavBar()),
                            (route) => false);
                      },
                      child: const Text("OK"))
                ],
              )
            ],
          );
        },
      );
    }
  }

  void errorPopup(
      {required String errorMessage, required BuildContext context}) {
    if (Navigator.canPop(context)) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          title: Column(
            children: [
              Text(
                errorMessage,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              )
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Ok"),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10.0), // Adjust as needed
                      side: BorderSide(color: Colors.blue, width: 2.0)),
                ),
              ),
            )
          ],
        ),
      );
      print('Error: $errorMessage');
    }
  }
}
