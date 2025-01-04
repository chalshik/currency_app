import 'dart:convert';
import 'package:http/http.dart' as http;

Future<double?> fetchCurrencyRate(String currency, String type) async {
  final String apiUrl =
      'http://chigurick.pythonanywhere.com/currency/rate/$currency/';

  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (type == 'buy' && data.containsKey('buy')) {
        // Попробуем безопасно преобразовать строку в double
        return double.tryParse(data['buy'].toString());
      } else if (type == 'sell' && data.containsKey('sell')) {
        return double.tryParse(data['sell'].toString());
      }
    } else {
      final errorData = jsonDecode(response.body);
      print('Error: ${errorData['error']}');
    }
  } catch (e) {
    print('Request failed: $e');
  }
  return null; // Возвращаем null, если произошла ошибка или данные не найдены
}

Future<List<String>> getCurrencies() async {
  final String apiUrl =
      'http://chigurick.pythonanywhere.com/currency/currencies/'; // URL вашего API
  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> currenciesData = jsonDecode(response.body);
      // Возвращаем список валют
      return currenciesData
          .map((currency) => currency['name'] as String)
          .toList();
    } else {
      print('Error: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Request failed: $e');
    return [];
  }
}
