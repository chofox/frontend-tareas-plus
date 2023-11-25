import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'categorias_screen.dart';
import 'prioridades_screen.dart';
import 'tareas_screen.dart'; // Importa la pantalla de tareas

class WelcomeScreen extends StatelessWidget {
  final String userName;
  final bool isLoggedIn;

  WelcomeScreen({required this.userName, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '¡Bienvenido, $userName!',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            if (isLoggedIn)
              ElevatedButton(
                onPressed: () {
                  // Navega a la pantalla de Categorías
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoriasScreen(),
                    ),
                  );
                },
                child: Text('Ir a Categorías'),
              ),
            if (isLoggedIn)
              ElevatedButton(
                onPressed: () {
                  // Navega a la pantalla de Prioridades
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrioridadesScreen(),
                    ),
                  );
                },
                child: Text('Ir a Prioridades'),
              ),
            if (isLoggedIn)
              ElevatedButton(
                onPressed: () {
                  // Navega a la pantalla de Tareas
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TareasScreen(),
                    ),
                  );
                },
                child: Text('Ir a Tareas'),
              ),
          ],
        ),
      ),
    );
  }
}
