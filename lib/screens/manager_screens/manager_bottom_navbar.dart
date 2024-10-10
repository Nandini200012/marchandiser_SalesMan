import 'package:flutter/material.dart';
import 'package:marchandise/screens/manager_screens/manager_dashboard_screen.dart';
import 'package:marchandise/screens/manager_screens/manager_home_screen.dart';

class ManagerBottomNavBar extends StatefulWidget {
  const ManagerBottomNavBar({super.key});

  @override
  State<ManagerBottomNavBar> createState() => _ManagerBottomNavBarState();
}

class _ManagerBottomNavBarState extends State<ManagerBottomNavBar> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          ManagerHomeScreen(),
          ManagerDashboardScreen(),
          // MangerProfile()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 207, 68, 18),
        elevation: 0,
        selectedItemColor: Colors.white,
        currentIndex: currentIndex,
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
            icon: Icon(Icons.space_dashboard),
            label: '',
          ),
        ],
      ),
    );
  }
}
