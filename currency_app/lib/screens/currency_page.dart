import 'package:flutter/material.dart';
import 'package:currency_app/logic/currency_logic.dart';
import 'add_currency_page.dart'; // Подключаем AddCurrencyPage

class DollarPage extends StatefulWidget {
  const DollarPage({super.key});

  @override
  _DollarPageState createState() => _DollarPageState();
}

class _DollarPageState extends State<DollarPage> {
  late Future<List<Map<String, dynamic>>> currencies;

  @override
  void initState() {
    super.initState();
    currencies = fetchCurrencies(); // Загружаем валюты при инициализации
  }

  Future<void> _refreshCurrencies() async {
    setState(() {
      currencies = fetchCurrencies(); // Обновляем данные валют
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currencies'),
        actions: [
          // Кнопка "Add" для добавления новой валюты
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // Открываем экран для добавления валюты
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddCurrencyPage()),
              );
              _refreshCurrencies();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        // Используем FutureBuilder для загрузки данных
        future: currencies,
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

          final data = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Заголовок страницы
                const Text(
                  'Волюты и их количества в отношению к сому ',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // Используем Expanded для таблицы, чтобы она заполнила доступное пространство
                Expanded(
                  child: SingleChildScrollView(
                    child: DataTable(
                      columnSpacing:
                          16.0, // Увеличиваем пространство между колонками
                      headingRowHeight: 56.0, // Увеличиваем высоту заголовков
                      dataRowHeight: 56.0, // Увеличиваем высоту строк
                      columns: const <DataColumn>[
                        DataColumn(
                          label:
                              Text('Currency', style: TextStyle(fontSize: 18)),
                        ),
                        DataColumn(
                          label: Text('Amount', style: TextStyle(fontSize: 18)),
                        ),
                      ],
                      rows: data
                          .map(
                            (currency) => DataRow(
                              cells: <DataCell>[
                                DataCell(
                                  Text(currency['name'] ?? '',
                                      style: TextStyle(fontSize: 16)),
                                ),
                                DataCell(
                                  Text(currency['amount'].toString(),
                                      style: TextStyle(fontSize: 16)),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
