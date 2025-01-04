import 'package:flutter/material.dart';
import 'package:currency_app/logic/login_request.dart';
import 'package:currency_app/screens/main_page.dart'; // Импортируем страницу HomeScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Функция для выполнения логина
  Future<void> _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    // Проверка на пустые поля
    if (username.isEmpty || password.isEmpty) {
      _showMessage('Username and password are required.', Colors.red);
      return;
    }

    // Запрос на сервер
    var response = await loginRequest(username, password);

    // Показываем сообщение в зависимости от результата
    if (response['success']) {
      _showMessage(
          'Login successful, welcome ${response['username']}', Colors.green);

      // Переход на экран HomeScreen после успешного логина
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      _showMessage(response['message'], Colors.red);
    }
  }

  // Функция для отображения уведомлений через SnackBar
  void _showMessage(String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
