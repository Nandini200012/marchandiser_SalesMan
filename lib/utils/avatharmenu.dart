import 'package:flutter/material.dart';

class AvatarWithMenu extends StatelessWidget {
  final String? txt;

  const AvatarWithMenu({super.key, this.txt=""});
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        // Handle menu item selection
        print('Selected: $value');
      },
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'item1',
            child: Text('Item 1'),
          ),
          PopupMenuItem<String>(
            value: 'item2',
            child: Text('Item 2'),
          ),
          // Add more menu items as needed
        ];
      },
      child: CircleAvatar(
     child: Text(txt.toString()??""),
        // Replace with your avatar image
      ),
    );
  }
}
