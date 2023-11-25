import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Categoria {
  final int id;
  final String nombre;
  final String color;

  Categoria({
    required this.id,
    required this.nombre,
    required this.color,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['ID'],
      nombre: json['Nombre'],
      color: json['Color'],
    );
  }
}

class CategoriasScreen extends StatefulWidget {
  @override
  _CategoriasScreenState createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  List<Categoria> categorias = [];
  Categoria? selectedCategoria;
  TextEditingController nombreController = TextEditingController();
  String selectedColor = 'Rojo'; // Por defecto, selecciona el primer color
  List<String> coloresEnEspanol = [
    'Rojo',
    'Azul',
    'Verde',
    'Amarillo',
    'Naranja',
    'Rosa',
    'Morado',
    'Marrón',
    'Gris',
    'Negro',
    'Blanco',
    'Celeste',
  ];

  Future<void> _fetchCategorias() async {
    try {
      final response = await http.get(
        Uri.parse('https://zzld1v2d-8080.use2.devtunnels.ms/categorias'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Categoria> fetchedCategorias =
            data.map((item) => Categoria.fromJson(item)).toList();

        setState(() {
          categorias = fetchedCategorias;
        });
      } else {
        print(
            'Error al obtener categorías. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en la solicitud de categorías: $e');
    }
  }

  Future<void> _createCategoria() async {
    try {
      final response = await http.post(
        Uri.parse('https://zzld1v2d-8080.use2.devtunnels.ms/categorias'),
        body: json.encode({
          'nombre': nombreController.text,
          'color': selectedColor,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        print('Categoría creada exitosamente');
        _fetchCategorias();
        _showSnackbar('Categoría creada exitosamente');
      } else {
        print(
            'Error al crear categoría. Código de estado: ${response.statusCode}');
        _showSnackbar('Error al crear categoría');
      }
    } catch (e) {
      print('Error al crear categoría: $e');
      _showSnackbar('Error al crear categoría');
    }
  }

  Future<void> _updateCategoria(Categoria categoria) async {
    try {
      final response = await http.put(
        Uri.parse(
            'https://zzld1v2d-8080.use2.devtunnels.ms/categorias/${categoria.id}'),
        body: json.encode({
          'nombre': nombreController.text,
          'color': selectedColor,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 204) {
        print('Categoría actualizada exitosamente');
        _fetchCategorias();
        _showSnackbar('Categoría actualizada exitosamente');
      } else {
        print(
            'Error al actualizar categoría. Código de estado: ${response.statusCode}');
        _showSnackbar('Error al actualizar categoría');
      }
    } catch (e) {
      print('Error al actualizar categoría: $e');
      _showSnackbar('Error al actualizar categoría');
    }
  }

  Future<void> _deleteCategoria(Categoria categoria) async {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Eliminar Categoría'),
            content:
                Text('¿Estás seguro de que quieres eliminar esta categoría?'),
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
                        'https://zzld1v2d-8080.use2.devtunnels.ms/categorias/${categoria.id}'),
                  );

                  if (response.statusCode == 204) {
                    print('Categoría eliminada exitosamente');
                    _fetchCategorias();
                    Navigator.of(context).pop(); // Cerrar el diálogo
                  } else {
                    print(
                        'Error al eliminar categoría. Código de estado: ${response.statusCode}');
                  }
                },
                child: Text('Eliminar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error al eliminar categoría: $e');
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
    _fetchCategorias();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categorías'),
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
                DropdownButton<String>(
                  value: selectedColor,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedColor = newValue!;
                    });
                  },
                  items: coloresEnEspanol
                      .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedCategoria != null) {
                      _updateCategoria(selectedCategoria!);
                    } else {
                      _createCategoria();
                    }
                  },
                  child: Text(selectedCategoria != null
                      ? 'Actualizar Categoría'
                      : 'Crear Categoría'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                final categoria = categorias[index];
                return ListTile(
                  title: Text(categoria.nombre),
                  subtitle: Text(categoria.color),
                  onTap: () {
                    setState(() {
                      selectedCategoria = categoria;
                      nombreController.text = categoria.nombre;
                      selectedColor = categoria.color;
                    });
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          setState(() {
                            selectedCategoria = categoria;
                            nombreController.text = categoria.nombre;
                            selectedColor = categoria.color;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteCategoria(categoria);
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
            selectedCategoria = null;
            nombreController.text = '';
            selectedColor =
                coloresEnEspanol[0]; // Por defecto, selecciona el primer color
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
