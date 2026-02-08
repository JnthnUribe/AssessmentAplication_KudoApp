import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project.dart';

/// Servicio para comunicación con la API de KUDO
class ApiService {
  // URL base de la API (cambiar para producción)
  static const String baseUrl = 'http://localhost:5000/api';

  /// Obtiene la lista de todos los proyectos desde la API
  Future<List<Project>> fetchProjects() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/projects'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Project.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar proyectos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtiene un proyecto específico por ID
  Future<Project> fetchProjectById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/projects/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return Project.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Proyecto no encontrado');
    }
  }
}
