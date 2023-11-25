// main.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'welcome_screen.dart';
import 'register_screen.dart';
import 'categorias_screen.dart'; // Importa la pantalla de categorías
import 'categorias.dart';
import 'prioridades_screen.dart'; // Importa la pantalla de prioridades

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
  bool _isLoggedIn = false;

  Future<void> _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    final Map<String, String> loginData = {
      'CorreoElectronico': email,
      'Contrasena': password,
    };

    final String jsonData = json.encode(loginData);

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
      final nombre = responseData['nombre'];

      if (token != null &&
          token is String &&
          nombre != null &&
          nombre is String) {
        setState(() {
          _token = token;
          _userName = nombre;
          _isLoggedIn = true;
        });

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token);

        // Después de un inicio de sesión exitoso
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WelcomeScreen(
              userName: _userName,
              isLoggedIn: _isLoggedIn,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Error al procesar la respuesta del servidor. Token o nombre no válido.'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Inicio de sesión fallido'),
      ));
    }
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterScreen(),
      ),
    );
  }

  void _navigateToCategorias() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoriasScreen(),
      ),
    );
  }

  void _navigateToPrioridades() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrioridadesScreen(),
      ),
    );
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
            SizedBox(height: 10),
            TextButton(
              onPressed: _navigateToRegister,
              child: Text('¿No tienes una cuenta? Regístrate aquí.'),
            ),
            if (_isLoggedIn)
              TextButton(
                onPressed: _navigateToCategorias,
                child: Text('Ir a Categorías'),
              ),
            if (_token.isNotEmpty) Text('Token JWT: $_token'),
          ],
        ),
      ),
    );
  }
}
