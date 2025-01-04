import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> addOperationHistory(
    String operationType, String currency, double amount, double rate) async {
  // URL API эндпоинта
  final String apiUrl =
      'http://chigurick.pythonanywhere.com/currency/add_history/'; // Замените на ваш реальный URL API

  // Данные для POST-запроса
  final Map<String, dynamic> requestData = {
    'user': 1,
    'operation_type': operationType,
    'currency': currency,
    'amount': amount,
    'rate': rate,
  };

  try {
    // Отправляем POST-запрос
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestData), // Преобразуем данные в JSON
    );

    if (response.statusCode == 201) {
      // Если запрос успешен
      final responseData = jsonDecode(response.body);
      return 'Успешно: ${responseData['message']}';
    } else {
      // Если возникла ошибка на сервере
      final errorData = jsonDecode(response.body);
      return 'Ошибка: ${errorData['error']}';
    }
  } catch (e) {
    // В случае ошибок с запросом
    return 'Ошибка запроса: $e';
  }
}
