import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<User>> fetchUsers() async {
  final response = await http
      .get(Uri.parse('http://chigurick.pythonanywhere.com/accounts/users/'));

  if (response.statusCode == 200) {
    // Успешный ответ
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((user) => User.fromJson(user)).toList();
  } else {
    // Ошибка запроса
    throw Exception('Failed to load users');
  }
}

// Модель пользователя
class User {
  final int id;
  final String username;

  User({required this.id, required this.username});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
    );
  }
}

Future<Map<String, dynamic>> registerUser(
    String username, String password) async {
  final response = await http.post(
    Uri.parse('http://chigurick.pythonanywhere.com/accounts/register/'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'username': username, 'password': password}),
  );

  if (response.statusCode == 201) {
    // Успешная регистрация
    return jsonDecode(response.body);
  } else {
    // Ошибка регистрации
    throw Exception('Failed to register user: ${response.body}');
  }
}
