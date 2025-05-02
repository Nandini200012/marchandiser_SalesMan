import 'package:flutter/material.dart';
import 'package:marchandise/screens/model/comment_model.dart';

void showCommentPopup(BuildContext context) {
  List<Comment> comments = [
    Comment(
        username: 'Alice',
        content: 'Nice post!',
        date: DateTime.now().subtract(Duration(minutes: 5))),
    Comment(
        username: 'Bob',
        content: 'Interesting thoughts.',
        date: DateTime.now().subtract(Duration(hours: 1))),
    Comment(
        username: 'Alice',
        content: 'Nice post!',
        date: DateTime.now().subtract(Duration(minutes: 5))),
    Comment(
        username: 'Bob',
        content: 'Interesting thoughts.',
        date: DateTime.now().subtract(Duration(hours: 1))),
    Comment(
        username: 'Alice',
        content: 'Nice post!',
        date: DateTime.now().subtract(Duration(minutes: 5))),
    Comment(
        username: 'Bob',
        content: 'Interesting thoughts.',
        date: DateTime.now().subtract(Duration(hours: 1))),
    Comment(
        username: 'Alice',
        content: 'Nice post!',
        date: DateTime.now().subtract(Duration(minutes: 5))),
    Comment(
        username: 'Bob',
        content: 'Interesting thoughts.',
        date: DateTime.now().subtract(Duration(hours: 1))),
  ];

  void showAddCommentDialog(VoidCallback onCommentAdded) {
    TextEditingController _commentController = TextEditingController();
    TextEditingController _usernameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Comment'),
          content: SizedBox(
            width:
                MediaQuery.of(context).size.width * 0.68, // Manage width here
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Your name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter your comment',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_commentController.text.isNotEmpty &&
                    _usernameController.text.isNotEmpty) {
                  comments.add(
                    Comment(
                      username: _usernameController.text,
                      content: _commentController.text,
                      date: DateTime.now(),
                    ),
                  );
                  onCommentAdded(); // Rebuild main dialog
                }
                Navigator.pop(context);
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Comments'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.35, // Adjust width
              height: 300,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return ListTile(
                          leading: Icon(Icons.account_circle),
                          title: Text(comment.username),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(comment.content),
                              SizedBox(height: 4),
                              Text(
                                '${comment.date.toLocal()}'.split('.')[0],
                                style:
                                    TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.add_comment),
                      onPressed: () {
                        showAddCommentDialog(() {
                          setState(() {}); // Refresh comment list
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              )
            ],
          );
        },
      );
    },
  );
}
