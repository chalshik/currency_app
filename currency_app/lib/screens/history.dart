import 'package:flutter/material.dart';
import 'package:currency_app/logic/currency_logic.dart'; // Импортируйте функцию для получения данных
import 'package:intl/intl.dart';

class OperationsPage extends StatefulWidget {
  const OperationsPage({super.key});

  @override
  _OperationsPageState createState() => _OperationsPageState();
}

class _OperationsPageState extends State<OperationsPage> {
  late Future<List<Map<String, dynamic>>> operations;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    operations =
        fetchOperationsByType(_selectedType); // Загружаем операции по типу
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Operations List'),
        ),
        body: SingleChildScrollView(
          scrollDirection:
              Axis.horizontal, // Устанавливаем горизонтальное направление
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Фильтрация по типу операции
              DropdownButton<String>(
                value: _selectedType,
                items: <String>[
                  'buy',
                  'sell',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue;
                    operations = fetchOperationsByType(
                        _selectedType); // Загружаем заново при изменении фильтра
                  });
                },
                hint: const Text('Select Operation Type'),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: operations,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No data available.'));
                    } else {
                      var data = snapshot.data!;
                      return SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('User')),
                            DataColumn(label: Text('Operation Type')),
                            DataColumn(label: Text('Currency')),
                            DataColumn(label: Text('Rate')),
                            DataColumn(label: Text('Amount')),
                            DataColumn(label: Text('Total')),
                            DataColumn(label: Text('Timestamp')),
                          ],
                          rows: data.map((operation) {
                            return DataRow(
                              cells: [
                                DataCell(Text(operation['user'])),
                                DataCell(Text(operation['operation_type'])),
                                DataCell(Text(operation['currency'])),
                                DataCell(Text(operation['rate'])),
                                DataCell(Text(operation['amount'])),
                                DataCell(Text(operation['total'])),
                                DataCell(
                                  Text(
                                    DateFormat('yyyy-MM-dd HH:mm:ss').format(
                                      DateTime.parse(operation['timestamp']),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
