import 'package:http/http.dart' as http;

Future<void> getComments() async {
  final url =
      Uri.parse('https://marchandising.azurewebsites.net/api/getComments');

  final headers = {
    'accept': '*/*',
    'requestId': '1',
    'productId': '1',
  };

  try {
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      print('Comments fetched successfully!');
      print(response.body);
    } else {
      print('Failed to fetch comments. Status code: ${response.statusCode}');
      print(response.body);
    }
  } catch (e) {
    print('Error occurred: $e');
  }
}
