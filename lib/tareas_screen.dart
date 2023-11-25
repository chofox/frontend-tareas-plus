import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Tarea {
  final int id;
  final String titulo;
  final String descripcion;
  final String fechaVencimiento;
  final String estado;
  final int idCategoria;
  final int idPrioridad;
  final int idUsuario;

  Tarea({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fechaVencimiento,
    required this.estado,
    required this.idCategoria,
    required this.idPrioridad,
    required this.idUsuario,
  });

  factory Tarea.fromJson(Map<String, dynamic> json) {
    return Tarea(
      id: json['ID'],
      titulo: json['Titulo'],
      descripcion: json['Descripcion'],
      fechaVencimiento: json['FechaVencimiento'],
      estado: json['Estado'],
      idCategoria: json['IDCategoria'],
      idPrioridad: json['IDPrioridad'],
      idUsuario: json['IDUsuario'],
    );
  }
}

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

Future<String> tuFuncionParaObtenerTareas() async {
  final response = await http
      .get(Uri.parse('https://zzld1v2d-8080.use2.devtunnels.ms/tareas'));
  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Error al obtener tareas: ${response.statusCode}');
  }
}

Future<String> tuFuncionParaObtenerCategorias() async {
  final response = await http
      .get(Uri.parse('https://zzld1v2d-8080.use2.devtunnels.ms/categorias'));
  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Error al obtener categorías: ${response.statusCode}');
  }
}

Future<String> tuFuncionParaObtenerPrioridades() async {
  final response = await http
      .get(Uri.parse('https://zzld1v2d-8080.use2.devtunnels.ms/prioridades'));
  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Error al obtener prioridades: ${response.statusCode}');
  }
}

List<Tarea> tuFuncionParaProcesarTareas(String responseBody) {
  List<dynamic> data = json.decode(responseBody);
  List<Tarea> tareas = data.map((task) => Tarea.fromJson(task)).toList();
  return tareas;
}

List<Categoria> tuFuncionParaProcesarCategorias(String responseBody) {
  List<dynamic> data = json.decode(responseBody);
  List<Categoria> categorias =
      data.map((category) => Categoria.fromJson(category)).toList();
  return categorias;
}

List<Prioridad> tuFuncionParaProcesarPrioridades(String responseBody) {
  List<dynamic> data = json.decode(responseBody);
  List<Prioridad> prioridades =
      data.map((priority) => Prioridad.fromJson(priority)).toList();
  return prioridades;
}

class TareasScreen extends StatefulWidget {
  @override
  _TareasScreenState createState() => _TareasScreenState();
}

Future<void> crearTareaEnAPI(Map<String, dynamic> tareaData) async {
  final response = await http.post(
    Uri.parse('https://zzld1v2d-8080.use2.devtunnels.ms/tareas'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(tareaData),
  );

  if (response.statusCode == 201) {
    // Creación exitosa
    final Map<String, dynamic> responseData = json.decode(response.body);
    final int newTareaId = responseData['id'];
  } else {
    // Manejar error
  }
}

Future<void> eliminarTareaEnAPI(int tareaId) async {
  final response = await http.delete(
    Uri.parse('https://zzld1v2d-8080.use2.devtunnels.ms/tareas/$tareaId'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 204) {
    // Eliminación exitosa
  } else {
    // Manejar error
  }
}

class _TareasScreenState extends State<TareasScreen> {
  TextEditingController idCategoriaController = TextEditingController();
  TextEditingController idPrioridadController = TextEditingController();

  List<Tarea> tareas = [];
  Tarea? selectedTarea;
  TextEditingController tituloController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();
  TextEditingController fechaController = TextEditingController();
  String selectedEstado = 'Pendiente';
  List<Categoria> categorias = [];
  List<Prioridad> prioridades = [];

  Future<void> _fetchData() async {
    try {
      // Obtener tareas, categorías y prioridades desde la API
      List<Tarea> fetchedTareas =
          await tuFuncionParaProcesarTareas(await tuFuncionParaObtenerTareas());
      List<Categoria> fetchedCategorias = await tuFuncionParaProcesarCategorias(
          await tuFuncionParaObtenerCategorias());
      List<Prioridad> fetchedPrioridades =
          await tuFuncionParaProcesarPrioridades(
              await tuFuncionParaObtenerPrioridades());

      setState(() {
        tareas = fetchedTareas;
        categorias = fetchedCategorias;
        prioridades = fetchedPrioridades;

        // Establecer valores iniciales si hay datos
        if (categorias.isNotEmpty) {
          selectedTarea?.categoria = categorias[0];
          idCategoriaController.text = categorias[0].id.toString();
        }

        if (prioridades.isNotEmpty) {
          selectedTarea?.prioridad = prioridades[0];
          idPrioridadController.text = prioridades[0].id.toString();
        }
      });
    } catch (e) {
      print('Error al obtener datos: $e');
      _showSnackbar('Error al obtener datos');
    }
  }

  Future<void> _createOrUpdateTarea() async {
    try {
      Map<String, dynamic> tareaData = {
        'titulo': tituloController.text,
        'descripcion': descripcionController.text,
        'fecha_vencimiento': fechaController.text,
        'estado': selectedEstado,
        'id_categoria': int.parse(idCategoriaController.text),
        'id_prioridad': int.parse(idPrioridadController.text),
        'id_usuario': 3,
      };

      if (selectedTarea != null) {
        // Actualizar tarea existente
        await actualizarTareaEnAPI(selectedTarea!.id, tareaData);
        _showSnackbar('Tarea actualizada exitosamente');
      } else {
        // Crear nueva tarea
        await crearTareaEnAPI(tareaData);
        _showSnackbar('Tarea creada exitosamente');
      }

      // Actualizar la lista de tareas después de la operación
      await _fetchData();
    } catch (e) {
      print('Error al crear/actualizar tarea: $e');
      _showSnackbar('Error al crear/actualizar tarea');
    }
  }

  Future<void> _deleteTarea() async {
    try {
      if (selectedTarea != null) {
        // Eliminar tarea existente
        await eliminarTareaEnAPI(selectedTarea!.id);
        _showSnackbar('Tarea eliminada exitosamente');

        // Actualizar la lista de tareas después de la operación
        await _fetchData();
      }
    } catch (e) {
      print('Error al eliminar tarea: $e');
      _showSnackbar('Error al eliminar tarea');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    // Llamar a la función para obtener datos cuando se inicializa el widget
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tareas'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seleccionar Tarea (Dropdown)
              DropdownButton<Tarea>(
                value: selectedTarea,
                onChanged: (Tarea? newValue) {
                  setState(() {
                    selectedTarea = newValue;
                    tituloController.text = newValue?.titulo ?? '';
                    descripcionController.text = newValue?.descripcion ?? '';
                    fechaController.text = newValue?.fechaVencimiento ?? '';
                    selectedEstado = newValue?.estado ?? 'Pendiente';
                    idCategoriaController.text =
                        newValue?.idCategoria.toString() ?? '';
                    idPrioridadController.text =
                        newValue?.idPrioridad.toString() ?? '';
                  });
                },
                items: tareas.map((Tarea tarea) {
                  return DropdownMenuItem<Tarea>(
                    value: tarea,
                    child: Text(tarea.titulo),
                  );
                }).toList(),
              ),

              // Campos de entrada para la Tarea
              TextField(
                controller: tituloController,
                decoration: InputDecoration(labelText: 'Título de la Tarea'),
              ),
              TextField(
                controller: descripcionController,
                decoration:
                    InputDecoration(labelText: 'Descripción de la Tarea'),
              ),
              TextField(
                controller: fechaController,
                decoration: InputDecoration(labelText: 'Fecha de Vencimiento'),
              ),

              // Dropdown para Estado
              DropdownButton<String>(
                value: selectedEstado,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedEstado = newValue!;
                  });
                },
                items: <String>['Pendiente', 'Completada', 'En Proceso']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),

              // Dropdown para Categoría
              DropdownButtonFormField<String>(
                value: idCategoriaController.text,
                onChanged: (String? newValue) {
                  setState(() {
                    idCategoriaController.text = newValue!;
                  });
                },
                items: categorias.map((Categoria categoria) {
                  return DropdownMenuItem<String>(
                    value: categoria.id.toString(),
                    child: Text(categoria.nombre),
                  );
                }).toList(),
              ),

              // Dropdown para Prioridad
              DropdownButtonFormField<String>(
                value: idPrioridadController.text,
                onChanged: (String? newValue) {
                  setState(() {
                    idPrioridadController.text = newValue!;
                  });
                },
                items: prioridades.map((Prioridad prioridad) {
                  return DropdownMenuItem<String>(
                    value: prioridad.id.toString(),
                    child: Text(prioridad.nombre),
                  );
                }).toList(),
              ),

              // Botones para acciones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: _createOrUpdateTarea,
                    child: Text('Guardar'),
                  ),
                  ElevatedButton(
                    onPressed: _deleteTarea,
                    child: Text('Eliminar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TareasScreen(),
  ));
}
