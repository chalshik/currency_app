import 'package:http/http.dart' as http;

Future<void> clearHistoryAndStats() async {
  final url = Uri.parse(
      'http://chigurick.pythonanywhere.com/currency/clear_data/'); // URL API для очистки истории и статистики

  try {
    final response = await http.post(url);

    if (response.statusCode == 200) {
      print('History and stats cleared successfully');
    } else {
      print('Failed to clear history and stats: ${response.statusCode}');
    }
  } catch (e) {
    print('Error occurred: $e');
  }
}
