import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/project.dart';

/// Servicio para comunicación con la API de KUDO
class ApiService {
  // URL de producción en Render
  static const String _renderUrl =
      'https://assessmentaplication-kudoapp.onrender.com/api';
  static const String _emulatorUrl = 'http://10.0.2.2:5145/api';

  static String get baseUrl {
    // Selección dinámica del entorno
    if (kIsWeb) {
      return _renderUrl; // Web siempre usa producción
    } else if (const bool.fromEnvironment('dart.vm.product')) {
      return _renderUrl; // Producción
    } else {
      return _emulatorUrl; // Emulador
    }
  }

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

  /// Busca un proyecto por su token QR
  Future<Project?> fetchProjectByQrToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/projects/qr/$token'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return Project.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Envía un voto real al servidor
  /// Retorna: {success: bool, message: String, alreadyVoted: bool}
  Future<Map<String, dynamic>> submitVote({
    required String projectId,
    required String voterId,
    required int score,
    String comment = '',
    List<String> tags = const [],
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/votes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'projectId': projectId,
          'voterId': voterId,
          'score': score,
          'comment': comment,
          'tags': tags,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? '¡Voto registrado!',
        };
      } else if (response.statusCode == 409) {
        return {
          'success': false,
          'message': data['message'] ?? 'Ya votaste',
          'alreadyVoted': true,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al votar',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// Verifica si un voterId ya votó por un proyecto
  Future<Map<String, dynamic>> checkVote({
    required String projectId,
    required String voterId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/votes/check?projectId=$projectId&voterId=$voterId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'hasVoted': false, 'score': 0};
    } catch (e) {
      return {'hasVoted': false, 'score': 0};
    }
  }

  // ── Comments ──

  /// Obtiene los comentarios de un proyecto
  Future<List<Map<String, dynamic>>> fetchComments(String projectId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/comments/project/$projectId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Publica un comentario
  Future<Map<String, dynamic>> submitComment({
    required String projectId,
    required String authorName,
    required String text,
    List<String> tags = const [],
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/comments'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'projectId': projectId,
          'authorName': authorName,
          'text': text,
          'tags': tags,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Publicado'};
      }
      return {'success': false, 'message': data['message'] ?? 'Error'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// Crea un nuevo proyecto en la base de datos
  Future<Project> createProject(Project project) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/projects'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(project.toJson()),
      );

      if (response.statusCode == 201) {
        return Project.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al crear proyecto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Actualiza un proyecto existente en la base de datos
  Future<Project> updateProject(String id, Project project) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/projects/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(project.toJson()),
      );

      if (response.statusCode == 200) {
        return Project.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al actualizar proyecto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
