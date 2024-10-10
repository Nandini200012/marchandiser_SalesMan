import 'package:flutter/material.dart';

class Willpop {
  DateTime? lastPressedAt;
  late BuildContext context;

  Willpop(this.context);

  bool onWillPop() {
    final now = DateTime.now();
    if (lastPressedAt == null ||
        now.difference(lastPressedAt!) > const Duration(seconds: 2)) {
      lastPressedAt = now;
     ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
     
          content:SizedBox(
            // width: MediaQuery.of(context).size.width-20,
            child: const Text("Press back again to exit")),
          duration:const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20.0), 
          ),
          behavior: SnackBarBehavior.floating, 
        ),
      );
      return false;
    }
    return true;
  }
}

