import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:currency_app/logic/currency_logic.dart';

class AddCurrencyPage extends StatefulWidget {
  const AddCurrencyPage({super.key});

  @override
  _AddCurrencyPageState createState() => _AddCurrencyPageState();
}

class _AddCurrencyPageState extends State<AddCurrencyPage> {
  List<String> _currencies = [];
  String? _selectedCurrency;
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    try {
      final response = await http.get(
        Uri.parse('http://chigurick.pythonanywhere.com/currency/availbale/'),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('available_currencies')) {
          setState(() {
            _currencies = List<String>.from(data['available_currencies']);
            _selectedCurrency = _currencies.isNotEmpty ? _currencies[0] : null;
          });
        } else {
          print('Error: available_currencies not found in response.');
        }
      } else {
        print('Error fetching currencies: ${response.statusCode}');
        setState(() {
          _currencies = [];
        });
      }
    } catch (e) {
      print('Error fetching currencies: $e');
      setState(() {
        _currencies = [];
      });
    }
  }

  void _showKgsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Amount for KGS', style: TextStyle(fontSize: 18)),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 18), // Увеличиваем размер шрифта
              textInputAction: TextInputAction.done,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрываем диалог
                double? amount = double.tryParse(_amountController.text);
                if (amount != null) {
                  addCurrency('KGS',
                      amount); // Вызываем addCurrency с введенным количеством
                } else {
                  // Можно обработать ошибку ввода (например, показать alert)
                  print("Invalid amount for KGS");
                }
              },
              child: Text('OK', style: TextStyle(fontSize: 18)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрытие без действия
              },
              child: Text('Cancel', style: TextStyle(fontSize: 18)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Currency', style: TextStyle(fontSize: 24)),
      ),
      body: Center(
        // Центрируем все виджеты в теле экрана
        child: Padding(
          padding: const EdgeInsets.all(
              32.0), // Увеличиваем отступы для лучшего восприятия
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Комбобокс для выбора валюты
              DropdownButton<String>(
                value: _selectedCurrency,
                hint: Text('Select Currency', style: TextStyle(fontSize: 20)),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCurrency = newValue;
                  });
                },
                items: _currencies
                    .map<DropdownMenuItem<String>>((String currency) {
                  return DropdownMenuItem<String>(
                    value: currency,
                    child: Text(currency, style: TextStyle(fontSize: 20)),
                  );
                }).toList(),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_selectedCurrency != null) {
                    // Ожидаем выполнения функции
                    String result = await addCurrency(_selectedCurrency!, 0.0);

                    // Показываем результат в Snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result)),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Please select a currency first!')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  minimumSize: Size(200, 50),
                ),
                child: Text('Add Currency', style: TextStyle(fontSize: 20)),
              ),
              SizedBox(height: 24),

              ElevatedButton(
                onPressed: _showKgsDialog,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  minimumSize: Size(200, 50),
                ),
                child: Text('Add KGS', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
