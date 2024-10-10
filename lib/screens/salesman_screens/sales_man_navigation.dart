// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:marchandise/screens/salesman_screens/salesman_dashboard_screen.dart';
// import 'package:marchandise/screens/salesman_screens/salesman_home_screen.dart';

// class SalesManBottomNavigation extends StatefulWidget {
//   const SalesManBottomNavigation({super.key});

//   @override
//   State<SalesManBottomNavigation> createState() =>
//       _SalesManBottomNavigationState();
// }

// class _SalesManBottomNavigationState extends State<SalesManBottomNavigation> {
//   @override
//   Widget build(BuildContext context) {
//     return CupertinoTabScaffold(
//         tabBar: CupertinoTabBar(
//           backgroundColor: Colors.blue,
//             activeColor: Colors.white,
//             items: const <BottomNavigationBarItem>[
//               BottomNavigationBarItem(
//                   icon: Icon(Icons.home_outlined), label: ""),
//               BottomNavigationBarItem(
//                   icon: Icon(Icons.space_dashboard_outlined),
//                   label: ""),
//               // BottomNavigationBarItem(
//               //     icon: Icon(CupertinoIcons.person), label: ""),
//             ]),
//         tabBuilder: (context, index) {
//           switch (index) {
//             case 0:
//               return CupertinoTabView(
//                 builder: (context) {
//                   return CupertinoPageScaffold(
//                     child: SalesmanHomeScreen(),
//                   );
//                 },
//               );

//                case 1:
//               return CupertinoTabView(
//                 builder: (context) {
//                   return CupertinoPageScaffold(
//                     child: SalesmanDashboardScreen(),
//                   );
//                 },
//               );

//               //  case 2:
//               // return CupertinoTabView(
//               //   builder: (context) {
//               //     return CupertinoPageScaffold(
//               //       child: SalesManProfile(),
//               //     );
//               //   },
//               // );

//             default:
//           }
//           return Container();
//         });
//   }
// }
