// currency_table.dart

import 'package:flutter/material.dart';
import 'package:currency_app/logic/currency_logic.dart';

class CurrencyTableScreen extends StatefulWidget {
  const CurrencyTableScreen({super.key});

  @override
  _CurrencyTableScreenState createState() => _CurrencyTableScreenState();
}

class _CurrencyTableScreenState extends State<CurrencyTableScreen> {
  late Future<List<Map<String, dynamic>>> currencies;

  @override
  void initState() {
    super.initState();
    currencies = fetchCurrencies(); // Загружаем валюты при инициализации
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currencies'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: currencies, // Используем нашу функцию для получения данных
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No currencies available.'));
          }

          // Получаем список валют из snapshot
          final data = snapshot.data!;

          return SingleChildScrollView(
            child: DataTable(
              columns: const <DataColumn>[
                DataColumn(label: Text('Currency')),
                DataColumn(label: Text('Amount')),
              ],
              rows: data
                  .map(
                    (currency) => DataRow(
                      cells: <DataCell>[
                        DataCell(Text(currency['name'] ?? '')),
                        DataCell(Text(currency['amount'].toString())),
                      ],
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
