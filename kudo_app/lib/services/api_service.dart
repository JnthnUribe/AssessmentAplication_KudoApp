import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/project.dart';

/// Servicio para comunicación con la API de KUDO
class ApiService {
  // PWA (web) usa localhost, dispositivo físico usa IP de red local
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5145/api';
    }
    // Para dispositivo físico Android, cambiar a tu IP local
    return 'http://10.0.2.2:5145/api';
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

  /// Envía un voto real al servidor
  /// Retorna: {success: bool, message: String, alreadyVoted: bool}
  Future<Map<String, dynamic>> submitVote({
    required String projectId,
    required String voterId,
    required int score,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/votes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'projectId': projectId,
          'voterId': voterId,
          'score': score,
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
}
