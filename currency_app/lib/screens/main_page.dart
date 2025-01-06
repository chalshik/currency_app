import 'package:currency_app/logic/add_history.dart';
import 'package:currency_app/logic/clear_history.dart';
import 'package:currency_app/logic/currency_logic.dart';
import 'package:currency_app/screens/currency_page.dart';
import 'package:currency_app/screens/stat.dart';
import 'package:currency_app/screens/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:currency_app/logic/main_page_func.dart';
import 'package:currency_app/screens/history.dart';

const Map<String, String> currencySymbols = {
  "RUB": "₽", // Российский рубль
  "GBP": "£", // Британский фунт
  "UZS": "сум", // Узбекский сум
  "CNY": "¥", // Китайский юань
  "KZT": "₸", // Казахстанский тенге
  "TRY": "₺", // Турецкая лира
  "EUR": "€", // Евро
  "USD": "\$", // Доллар США
};

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
  String symbol = "\$";
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
                    SizedBox(width: 80),
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
                  height: 20,
                ),
                Row(
                  mainAxisSize: MainAxisSize
                      .min, // Минимальный размер для row, чтобы содержимое не растягивалось
                  mainAxisAlignment: MainAxisAlignment
                      .center, // Центрирование элементов в ряду
                  children: [
                    // Символ валюты
                    Text(
                      currencySymbols[_currency] ??
                          '?', // Безопасное обращение к словарю
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                        width: 8), // Отступ между символом валюты и количеством

                    // Сумма (с двумя знаками после запятой)
                    Text(
                      _amount != null
                          ? _amount!.toStringAsFixed(2)
                          : 'N/A', // Безопасная проверка _amount
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                        width: 8), // Отступ между суммой и выпадающим списком

                    // Выпадающий список для выбора валюты
                    Container(
                      width: 120, // Устанавливаем ширину для удобства
                      child: DropdownButtonFormField<String>(
                        value: _currency,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.blue,
                          size: 34,
                        ),
                        style: const TextStyle(
                          fontSize: 22,
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
                          });
                          _getCurrencyRate();
                        },
                        decoration: InputDecoration(
                          isDense: false,
                          contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: 15,
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

                SizedBox(height: 24),
                // Поле для отображения курса
                TextField(
                  controller: _rateController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Rate',
                  ),
                  onChanged: (_) => _calculateProduct(),
                ),
                SizedBox(height: 24),
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
                    Material(
                      color: Colors.blue, // Цвет фона кнопки
                      shape: CircleBorder(), // Круглая форма
                      child: IconButton(
                        icon: Icon(Icons.add), // Иконка "Add"
                        iconSize: 40, // Размер иконки
                        color: Colors.white, // Цвет иконки
                        onPressed: () async {
                          // Считываем данные из текстовых полей
                          String operationType = _rateType;
                          String currency = _currency;
                          double amount =
                              double.tryParse(_controller1.text) ?? 0;
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
                            _controller1
                                .clear(); // Очистить поле для ввода суммы
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 50),
                    Column(
                      children: [
                        Material(
                          color: Colors.red, // Цвет фона
                          shape: CircleBorder(), // Круглая форма
                          child: IconButton(
                            icon: Icon(Icons.history), // Иконка send
                            iconSize: 40, // Размер иконки
                            color: Colors.white, // Цвет иконки
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OperationsPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    )
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
