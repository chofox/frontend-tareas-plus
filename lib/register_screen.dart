import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _register() async {
    final String name = _nameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    // Realiza la lógica de registro aquí
    // Puedes enviar una solicitud al servidor para manejar el registro

    // Ejemplo de validación básica
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Las contraseñas no coinciden.'),
      ));
      return;
    }

    final Map<String, String> registerData = {
      'Nombre': name,
      'CorreoElectronico': email,
      'Contrasena': password,
    };

    final String jsonData = json.encode(registerData);

    // Ejemplo de solicitud al servidor
    try {
      final response = await http.post(
        Uri.parse('https://zzld1v2d-8080.use2.devtunnels.ms/usuarios'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonData,
      );

      if (response.statusCode == 201) {
        // Registro exitoso, puedes mostrar un mensaje al usuario
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Registro exitoso. Bienvenido, $name!'),
        ));

        // Puedes agregar más lógica aquí, como navegar a la pantalla de inicio de sesión, etc.
      } else {
        // Si el servidor no responde con un código 201, intentamos obtener más detalles
        final Map<String, dynamic> errorData = json.decode(response.body);
        final errorMessage = errorData['error'];

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error en el registro: $errorMessage'),
        ));
      }
    } catch (error) {
      // Manejo de errores en caso de problemas de red u otros errores
      print('Error en la solicitud de registro: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Error en la solicitud de registro. Por favor, inténtalo nuevamente.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo Electrónico'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirmar Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}
