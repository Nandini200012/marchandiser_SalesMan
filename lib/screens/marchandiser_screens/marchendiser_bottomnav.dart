import 'package:flutter/material.dart';
import 'package:marchandise/screens/marchandiser_screens/create_request_screen.dart';
import 'package:marchandise/screens/marchandiser_screens/marchendiser_dashboard_screen.dart';

class MarchendiserBottomNavigation extends StatefulWidget {
  const MarchendiserBottomNavigation({super.key});

  @override
  State<MarchendiserBottomNavigation> createState() =>
      _MarchendiserBottomNavigationState();
}

class _MarchendiserBottomNavigationState
    extends State<MarchendiserBottomNavigation> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      body: IndexedStack(
        index: currentIndex,
        children: [
          MarchendiserDashboardScreen(),
          CreateRequestScreen(),
          // MarchendiserProfileScreen()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:
            Colors.transparent, // Set background color to transparent
        elevation: 0,
        selectedItemColor: Colors.white,
        currentIndex: currentIndex,
        showSelectedLabels: false, // Hide labels for selected items
        showUnselectedLabels: false,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.space_dashboard_outlined),
            label: '',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.person),
          //   label: '',
          // ),
        ],
      ),
    );
  }
}
