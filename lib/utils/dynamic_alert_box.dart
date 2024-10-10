import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marchandise/screens/salesman_screens/salesman_bottom_navbar.dart';

class DynamicAlertBox {
  void showPopUpForSaving(
      context, String content, String btnText1, String btnText2) {
    showDialog(
      context: context,
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return AlertDialog(
              actionsAlignment: MainAxisAlignment.center,
              title: Column(
                children: [
                  Text(content,
                      style: TextStyle(
                          fontSize:
                          constraints.maxWidth > 600 ? 5.sp : 16.sp)),
                ],
              ),
              actions: [
                TextButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                            "Request Updated Successfully",
                            style: TextStyle(
                                fontSize:
                                constraints.maxWidth > 600 ? 5.sp : 16.sp),
                          ),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10.0),
                                        side: const BorderSide(color: Colors.blue),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const SalesManBottomNavBar()),
                                            (route) => false);
                                  },
                                  child: Text("OK",
                                      style: TextStyle(
                                          fontSize: constraints.maxWidth > 600
                                              ? 5.sp
                                              : 14.sp)),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text(btnText1,
                      style: TextStyle(
                          fontSize:
                          constraints.maxWidth > 600 ? 5.sp : 14.sp)),
                ),
                TextButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(btnText2,
                      style: TextStyle(
                          fontSize:
                          constraints.maxWidth > 600 ? 5.sp : 14.sp)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void logOut(context, String message, VoidCallback onTap) {
    showDialog(
      context: context,
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return AlertDialog(
              actionsAlignment: MainAxisAlignment.center,
              title: Column(
                children: [
                  Text(message,
                      style: TextStyle(
                          fontSize:
                          constraints.maxWidth > 600 ? 5.sp : 16.sp)),
                  SizedBox(height: 5.h),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      style: ButtonStyle(
                        side: MaterialStateProperty.all(
                          const BorderSide(color: Colors.blue, width: 2.0),
                        ),
                      ),
                      onPressed: onTap,
                      child: Text("Yes",
                          style: TextStyle(
                              fontSize:
                              constraints.maxWidth > 600 ? 5.sp : 14.sp)),
                    ),
                    SizedBox(width: constraints.maxWidth > 600 ? 8.w : 15.w),
                    TextButton(
                      style: ButtonStyle(
                        side: MaterialStateProperty.all(
                          const BorderSide(color: Colors.blue, width: 2.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("No",
                          style: TextStyle(
                              fontSize:
                              constraints.maxWidth > 600 ? 5.sp : 14.sp)),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
