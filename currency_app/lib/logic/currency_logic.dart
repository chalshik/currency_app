import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Map<String, dynamic>>> fetchCurrencies() async {
  final response = await http.get(
      Uri.parse('http://chigurick.pythonanywhere.com/currency/currencies/'));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((item) => item as Map<String, dynamic>).toList();
  } else {
    throw Exception('Failed to load currencies');
  }
}

Future<double?> getAmountByCurrency(String currencyName) async {
  try {
    List<Map<String, dynamic>> currencies = await fetchCurrencies();
    // Находим валюту по имени
    var currency = currencies.firstWhere((item) => item['name'] == currencyName,
        orElse: () => {});
    return currency.isNotEmpty ? currency['amount'] : null;
  } catch (e) {
    print('Error: $e');
    return null;
  }
}

Future<String> addCurrency(String currencyName, double amount) async {
  final url =
      Uri.parse('http://chigurick.pythonanywhere.com/currency/add_currency/');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'name': currencyName.toString(),
      'amount': amount.toString(),
    }),
  );

  if (response.statusCode == 201) {
    // Успешное добавление валюты
    return 'Succesfully added';
  } else {
    // Ошибка
    return 'Error';
  }
}

// Функция для получения статистики валют
Future<List<CurrencyStat>> fetchCurrencyStats() async {
  final response = await http
      .get(Uri.parse('http://chigurick.pythonanywhere.com/currency/stat/'));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((stat) => CurrencyStat.fromJson(stat)).toList();
  } else {
    throw Exception('Failed to load currency stats');
  }
}

class CurrencyStat {
  final String currency;
  final String totalBuy;
  final String totalSell;
  final String averageBuy;
  final String averageSell;
  final String profit;

  CurrencyStat({
    required this.currency,
    required this.totalBuy,
    required this.totalSell,
    required this.averageBuy,
    required this.averageSell,
    required this.profit,
  });

  factory CurrencyStat.fromJson(Map<String, dynamic> json) {
    return CurrencyStat(
      currency: json['currency'],
      totalBuy: json['total_buy'],
      totalSell: json['total_sell'],
      averageBuy: json['average_buy'],
      averageSell: json['average_sell'],
      profit: json['profit'],
    );
  }
}

Future<List<Map<String, dynamic>>> fetchOperationsByType(
    String? operationType) async {
  // Формируем URL с параметром фильтрации
  String url =
      'http://chigurick.pythonanywhere.com/currency/history/'; // Путь к вашему API
  if (operationType != null && operationType.isNotEmpty) {
    url +=
        '?operation_type=$operationType'; // Добавляем фильтр по типу операции
  }

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Парсим полученные данные
      List<dynamic> data = json.decode(response.body);
      return data
          .map((operation) => operation as Map<String, dynamic>)
          .toList();
    } else {
      throw Exception('Failed to load operations');
    }
  } catch (e) {
    print('Error fetching operations: $e');
    return [];
  }
}
