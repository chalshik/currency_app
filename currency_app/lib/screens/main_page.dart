import 'package:currency_app/logic/add_history.dart';
import 'package:currency_app/logic/clear_history.dart';
import 'package:currency_app/logic/currency_logic.dart';
import 'package:currency_app/screens/currency_page.dart';
import 'package:currency_app/screens/stat.dart';
import 'package:currency_app/screens/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:currency_app/logic/main_page_func.dart';
import 'package:currency_app/screens/history.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Main page',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  String _currency = "USD";
  String _rateType = "buy";
  String _sub = 'US';
  double? _amount;
  double? _rate;
  String _result = '';
  List<String> _currencies = [];

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    List<String> currencies = await getCurrencies();
    currencies = currencies.where((currency) => currency != "KGS").toList();

    setState(() {
      _currencies = currencies;
    });
  }

  void _calculateProduct() {
    double num1 = double.tryParse(_controller1.text) ?? 0;
    setState(() {
      _result = (_rate != null ? (num1 * _rate!) : 0).toString();
    });
  }

  Future<void> getAmount() async {
    // Получаем сумму для выбранной валюты
    double? amount = await getAmountByCurrency(_currency);
    setState(() {
      _amount = amount; // Обновляем значение amount
    });
  }

  Future<void> _getCurrencyRate() async {
    final rate = await fetchCurrencyRate(_currency, _rateType);
    if (rate != null) {
      setState(() {
        _rate = rate;
        _rateController.text = rate.toString();
      });
      await getAmount();
      _calculateProduct();
    } else {
      setState(() {
        _rateController.text = 'Error fetching rate';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100, // Цвет фона
      appBar: AppBar(
          title: Text('Operation'),
          centerTitle: true,
          leading: IconButton(
              onPressed: _loadCurrencies, icon: const Icon(Icons.refresh))),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _rateType = "buy";
                        });
                        _getCurrencyRate();
                      },
                      child: Icon(Icons.arrow_downward),
                    ),
                    SizedBox(width: 50),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _rateType = "sell";
                        });
                        _getCurrencyRate();
                      },
                      child: Icon(Icons.arrow_upward),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                    ),
                    Image.network(
                      "https://flagsapi.com/$_sub/flat/64.png",
                      width: 40,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      _amount.toString(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 90, // Уменьшаем ширину выпадающего списка
                          child: DropdownButtonFormField<String>(
                            value: _currency,
                            icon: Transform.translate(
                              offset: const Offset(0, -8),
                              child: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.blue,
                                size: 40,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                            items: _currencies.map((currency) {
                              return DropdownMenuItem<String>(
                                value: currency,
                                child: Text(currency),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _currency = value!;
                                _sub = _currency.substring(0, 2);
                              });
                              _getCurrencyRate();
                              // После выбора валюты получаем новый курс
                            },
                            decoration: const InputDecoration(
                              labelText: 'Select Currency',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                // Поле для ввода суммы
                TextField(
                  controller: _controller1,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Amount',
                  ),
                  onChanged: (_) => _calculateProduct(),
                ),

                SizedBox(height: 16),
                // Поле для отображения курса
                TextField(
                  controller: _rateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Rate',
                  ),
                  onChanged: (_) => _calculateProduct(),
                ),
                SizedBox(height: 16),
                // Карточка для отображения результата
                Divider(
                  color: Colors.black, // Цвет линии
                  thickness: 2, // Толщина линии
                  indent: 20, // Отступ слева
                  endIndent: 20, // Отступ справа
                ),
                Column(
                  children: [
                    Text(
                      "Your product:",
                      style: TextStyle(
                          fontSize: 12,
                          color: const Color.fromARGB(205, 0, 0, 0)),
                    ),
                    Text(
                      _result,
                      style: TextStyle(fontSize: 30),
                    )
                  ],
                ),

                SizedBox(height: 16),
                // Кнопки для добавления и просмотра истории
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // Считываем данные из текстовых полей
                        String operationType = _rateType;
                        String currency = _currency;
                        double amount = double.tryParse(_controller1.text) ?? 0;
                        double rate = _rate ?? 0;

                        // Вызываем функцию и получаем результат
                        String result = await addOperationHistory(
                            operationType, currency, amount, rate);
                        getAmount();
                        // Показываем SnackBar с результатом
                        if (_controller1.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Поле пустое!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }

                        // Очищаем текстовые поля
                        if (result.startsWith('Успешно')) {
                          _controller1.clear(); // Очистить поле для ввода суммы
                          // Добавьте аналогичный вызов для других контроллеров, если нужно
                        }
                      },
                      child: Text('Add'),
                    ),
                    SizedBox(width: 16),
                    Column(children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                              255, 44, 36, 197), // Красный цвет кнопки
                          shape: CircleBorder(), // Круглая форма
                          padding: EdgeInsets.all(20), // Отступы внутри кнопки
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OperationsPage()),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                    255, 44, 36, 197), // Цвет кнопки
                                shape: CircleBorder(), // Круглая форма
                                padding: EdgeInsets.all(
                                    10), // Меньше отступов для уменьшения размера кнопки
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OperationsPage(),
                                  ),
                                );
                              },
                              child: Icon(
                                Icons.send, // Иконка send
                                color: Colors.white, // Цвет иконки
                                size: 32, // Размер иконки
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Send', // Текст под кнопкой
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ])
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text(
                'Панель управления',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.attach_money),
              title: Text('Currencies'),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DollarPage()),
                );
                _loadCurrencies();
              },
            ),
            ListTile(
              leading: Icon(Icons.cleaning_services),
              title: Text('Clean'),
              onTap: () {
                // Показываем диалоговое окно подтверждения
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Подтверждение'),
                      content: Text(
                          'Вы уверены, что хотите очистить историю и статистику?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            // Закрыть диалог без действия
                            Navigator.of(context).pop();
                          },
                          child: Text('Нет'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Вызываем функцию и закрываем диалог
                            clearHistoryAndStats();
                            Navigator.of(context).pop();
                          },
                          child: Text('Да'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Users'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserListPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.trending_up),
              title: Text('Statistics'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CurrencyStatsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
