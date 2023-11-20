import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _token = '';
  String _userName = '';
  String _userEmail = '';

  Future<void> _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    // Muestra en la consola lo que estás ingresando
    print('Correo Electrónico: $email');
    print('Contraseña: $password');

    // Crea un mapa con los datos a enviar al servidor
    final Map<String, String> loginData = {
      'CorreoElectronico': email,
      'Contrasena': password,
    };

    // Convierte los datos a formato JSON
    final String jsonData = json.encode(loginData);

    // Muestra en la consola cómo se envían los datos al servidor
    print('Datos enviados al servidor (en formato JSON): $jsonData');

    final response = await http.post(
      Uri.parse('https://zzld1v2d-8080.use2.devtunnels.ms/usuarios/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonData,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final token = responseData['token'];

      setState(() {
        _token = token;
      });

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', token);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Inicio de sesión exitoso. Bienvenido, $_userName ($_userEmail).'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Inicio de sesión fallido'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio de Sesión'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo Electrónico'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _login,
              child: Text('Iniciar Sesión'),
            ),
            if (_token.isNotEmpty) Text('Token JWT: $_token'),
          ],
        ),
      ),
    );
  }
}
