import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> loginRequest(
    String username, String password) async {
  final String apiUrl =
      'http://chigurick.pythonanywhere.com/accounts/login/'; // Ваш API эндпоинт

  final Map<String, dynamic> requestData = {
    'username': username,
    'password': password,
  };

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      // Успешный запрос
      final responseData = jsonDecode(response.body);
      return {
        'success': true,
        'message': responseData['success'],
        'username': responseData['username']
      };
    } else if (response.statusCode == 400 || response.statusCode == 401) {
      // Ошибка на сервере
      final responseData = jsonDecode(response.body);
      return {'success': false, 'message': responseData['error']};
    } else {
      return {'success': false, 'message': 'Unexpected error occurred'};
    }
  } catch (e) {
    return {'success': false, 'message': 'Request failed: $e'};
  }
}
