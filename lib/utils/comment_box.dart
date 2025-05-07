import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marchandise/screens/model/comment_model.dart';
import 'package:marchandise/screens/salesman_screens/model/comment_model.dart';
import 'package:marchandise/services/comment/comments_post.dart';

void showCommentPopup(
  BuildContext context, {
  required int? requestID,
  required String? productID,
  required String? productName,
  int? uomID,
}) {
  List<CommentData> comments = [];

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> fetchComments() async {
            final url = Uri.parse(
              'https://marchandising.azurewebsites.net/api/getComments',
            );

            final headers = {
              'accept': '*/*',
              'requestId': requestID.toString(),
              'productId': productID.toString(),
              'uomID': uomID.toString(),
            };
            log('get header:$headers');
            try {
              final response = await http.get(url, headers: headers);
              log('fetching comments: ${response.statusCode},${response.body}');
              if (response.statusCode == 200) {
                final model = commentModelFromJson(response.body);
                setState(() {
                  comments = model.data;
                });
              } else {
                log('Error fetching comments: ${response.statusCode},${response.body}');
              }
            } catch (e) {
              log('Exception during fetch: $e');
            }
          }

          // Fetch comments only once when the dialog opens
          if (comments.isEmpty) fetchComments();

          void showAddCommentDialog(VoidCallback onCommentAdded) {
            final TextEditingController _commentController =
                TextEditingController();

            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Add Comment'),
                  content: TextField(
                    controller: _commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Enter your comment',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final commentText = _commentController.text.trim();
                        if (commentText.isNotEmpty) {
                          await addComment(
                            context,
                            requestID!,
                            productID!,
                            productName!,
                            commentText,
                            uomID,
                          );
                          Navigator.pop(context);
                          fetchComments();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please add a comment'),
                            ),
                          );
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                );
              },
            );
          }

          return AlertDialog(
            title: const Text('Comments'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.35,
              height: 300,
              child: Column(
                children: [
                  Expanded(
                    child: comments.isEmpty
                        ? Center(child: Text("Sorry! thers's no comment yet!"))
                        // ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              return ListTile(
                                leading: const Icon(Icons.account_circle),
                                title: Text(comment.userId),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(comment.comments),
                                    SizedBox(height: 4),
                                    Text(
                                      DateFormat('dd MMM yyyy, hh:mm a')
                                          .format(comment.createdDateTime),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 10,
                                          color: Colors.black),
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
                      icon: const Icon(Icons.add_comment),
                      onPressed: () {
                        showAddCommentDialog(() {
                          fetchComments(); // Refresh after adding comment
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
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    },
  );
}
