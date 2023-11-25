import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Prioridad {
  final int id;
  final String nombre;
  final String descripcion;

  Prioridad({
    required this.id,
    required this.nombre,
    required this.descripcion,
  });

  factory Prioridad.fromJson(Map<String, dynamic> json) {
    return Prioridad(
      id: json['ID'],
      nombre: json['Nombre'],
      descripcion: json['Descripcion'],
    );
  }
}

class PrioridadesScreen extends StatefulWidget {
  @override
  _PrioridadesScreenState createState() => _PrioridadesScreenState();
}

class _PrioridadesScreenState extends State<PrioridadesScreen> {
  List<Prioridad> prioridades = [];
  Prioridad? selectedPrioridad;
  TextEditingController nombreController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();

  Future<void> _fetchPrioridades() async {
    try {
      final response = await http.get(
        Uri.parse('https://zzld1v2d-8080.use2.devtunnels.ms/prioridades'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Prioridad> fetchedPrioridades =
            data.map((item) => Prioridad.fromJson(item)).toList();

        setState(() {
          prioridades = fetchedPrioridades;
        });
      } else {
        print(
            'Error al obtener prioridades. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en la solicitud de prioridades: $e');
    }
  }

  Future<void> _createPrioridad() async {
    try {
      final response = await http.post(
        Uri.parse('https://zzld1v2d-8080.use2.devtunnels.ms/prioridades'),
        body: json.encode({
          'nombre': nombreController.text,
          'descripcion': descripcionController.text,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        print('Prioridad creada exitosamente');
        _fetchPrioridades();
        _showSnackbar('Prioridad creada exitosamente');
      } else {
        print(
            'Error al crear prioridad. Código de estado: ${response.statusCode}');
        _showSnackbar('Error al crear prioridad');
      }
    } catch (e) {
      print('Error al crear prioridad: $e');
      _showSnackbar('Error al crear prioridad');
    }
  }

  Future<void> _updatePrioridad(Prioridad prioridad) async {
    try {
      final response = await http.put(
        Uri.parse(
            'https://zzld1v2d-8080.use2.devtunnels.ms/prioridades/${prioridad.id}'),
        body: json.encode({
          'nombre': nombreController.text,
          'descripcion': descripcionController.text,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 204) {
        print('Prioridad actualizada exitosamente');
        _fetchPrioridades();
        _showSnackbar('Prioridad actualizada exitosamente');
      } else {
        print(
            'Error al actualizar prioridad. Código de estado: ${response.statusCode}');
        _showSnackbar('Error al actualizar prioridad');
      }
    } catch (e) {
      print('Error al actualizar prioridad: $e');
      _showSnackbar('Error al actualizar prioridad');
    }
  }

  Future<void> _deletePrioridad(Prioridad prioridad) async {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Eliminar Prioridad'),
            content:
                Text('¿Estás seguro de que quieres eliminar esta prioridad?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar el diálogo
                },
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  final response = await http.delete(
                    Uri.parse(
                        'https://zzld1v2d-8080.use2.devtunnels.ms/prioridades/${prioridad.id}'),
                  );

                  if (response.statusCode == 204) {
                    print('Prioridad eliminada exitosamente');
                    _fetchPrioridades();
                    Navigator.of(context).pop(); // Cerrar el diálogo
                  } else {
                    print(
                        'Error al eliminar prioridad. Código de estado: ${response.statusCode}');
                  }
                },
                child: Text('Eliminar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error al eliminar prioridad: $e');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchPrioridades();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prioridades'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: descripcionController,
                  decoration: InputDecoration(labelText: 'Descripción'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedPrioridad != null) {
                      _updatePrioridad(selectedPrioridad!);
                    } else {
                      _createPrioridad();
                    }
                  },
                  child: Text(selectedPrioridad != null
                      ? 'Actualizar Prioridad'
                      : 'Crear Prioridad'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: prioridades.length,
              itemBuilder: (context, index) {
                final prioridad = prioridades[index];
                return ListTile(
                  title: Text(prioridad.nombre),
                  subtitle: Text(prioridad.descripcion),
                  onTap: () {
                    setState(() {
                      selectedPrioridad = prioridad;
                      nombreController.text = prioridad.nombre;
                      descripcionController.text = prioridad.descripcion;
                    });
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          setState(() {
                            selectedPrioridad = prioridad;
                            nombreController.text = prioridad.nombre;
                            descripcionController.text = prioridad.descripcion;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deletePrioridad(prioridad);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            selectedPrioridad = null;
            nombreController.text = '';
            descripcionController.text = '';
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
