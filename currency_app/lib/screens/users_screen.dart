import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'add_user.dart';

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

// Окно для отображения списка пользователей
class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  late Future<List<User>> _users;

  @override
  void initState() {
    super.initState();
    _users = fetchUsers();
  }

  Future<List<User>> fetchUsers() async {
    final response = await http
        .get(Uri.parse('http://chigurick.pythonanywhere.com/accounts/users/'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Переходим на экран регистрации и обновляем данные при возвращении
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              ).then((_) {
                setState(() {
                  _users = fetchUsers(); // Перезагружаем список пользователей
                });
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<User>>(
        future: _users,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.username),
                subtitle: Text('ID: ${user.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
