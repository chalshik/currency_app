import 'package:flutter/material.dart';
import 'package:currency_app/logic/currency_logic.dart';

class CurrencyStatsPage extends StatefulWidget {
  const CurrencyStatsPage({super.key});

  @override
  _CurrencyStatsPageState createState() => _CurrencyStatsPageState();
}

class _CurrencyStatsPageState extends State<CurrencyStatsPage> {
  late Future<List<CurrencyStat>> _currencyStats;
  late Future<List<Map<String, dynamic>>> _currencies;

  @override
  void initState() {
    super.initState();
    _currencyStats =
        fetchCurrencyStats(); // Загружаем статистику валют при запуске
    _currencies = fetchCurrencies(); // Получаем данные валют
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Currency Stats'),
        ),
        body: Center(
          child: FutureBuilder<List<CurrencyStat>>(
            future: _currencyStats, // Асинхронно загружаем статистику валют
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator()); // Загрузка
              } else if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error}')); // Ошибка
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                    child: Text('No data available.')); // Нет данных
              } else {
                final stats = snapshot.data!;
                double totalProfit = 0.0;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Таблица статистики
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 16.0,
                          headingRowHeight: 56.0,
                          dataRowHeight: 56.0,
                          columns: const [
                            DataColumn(
                                label: Text('Currency',
                                    style: TextStyle(fontSize: 18))),
                            DataColumn(
                                label: Text('Total Buy',
                                    style: TextStyle(fontSize: 18))),
                            DataColumn(
                                label: Text('Total Sell',
                                    style: TextStyle(fontSize: 18))),
                            DataColumn(
                                label: Text('Avg Buy',
                                    style: TextStyle(fontSize: 18))),
                            DataColumn(
                                label: Text('Avg Sell',
                                    style: TextStyle(fontSize: 18))),
                            DataColumn(
                                label: Text('Profit',
                                    style: TextStyle(fontSize: 18))),
                          ],
                          rows: stats.map((stat) {
                            totalProfit += double.tryParse(stat.profit) ?? 0.0;
                            return DataRow(
                              cells: [
                                DataCell(Text(stat.currency,
                                    style: TextStyle(fontSize: 16))),
                                DataCell(Text(stat.totalBuy,
                                    style: TextStyle(fontSize: 16))),
                                DataCell(Text(stat.totalSell,
                                    style: TextStyle(fontSize: 16))),
                                DataCell(Text(stat.averageBuy,
                                    style: TextStyle(fontSize: 16))),
                                DataCell(Text(stat.averageSell,
                                    style: TextStyle(fontSize: 16))),
                                DataCell(Text(stat.profit,
                                    style: TextStyle(fontSize: 16))),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Данные о прибыли и оставшемся количестве сомов
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _currencies, // Асинхронно загружаем валюты
                        builder: (context, currenciesSnapshot) {
                          if (currenciesSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator()); // Загрузка
                          } else if (currenciesSnapshot.hasError) {
                            return Center(
                                child: Text(
                                    'Error: ${currenciesSnapshot.error}')); // Ошибка
                          } else if (currenciesSnapshot.hasData) {
                            final currencies = currenciesSnapshot.data!;
                            final remainingSom = currencies.firstWhere(
                              (currency) => currency['name'] == 'KGS',
                              orElse: () => {'amount': 0.0},
                            )['amount'] as double;

                            return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Total Profit: ${totalProfit.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 20),
                                    Text(
                                      'Remaining Som: ${remainingSom.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ));
                          } else {
                            return const Center(
                                child: Text('No currencies data.'));
                          }
                        },
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ));
  }
}
