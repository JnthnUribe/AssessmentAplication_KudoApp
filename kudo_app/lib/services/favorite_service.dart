import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Servicio para manejar el proyecto favorito del usuario (solo 1)
class FavoriteService {
  static const String _favKey = 'kudo_favorite_project_id';
  static String? _cached;
  static const String _apiUrl = 'https://api.kudoapp.com/favorites';

  /// Obtiene el ID del proyecto favorito (null si no hay)
  static Future<String?> getFavoriteProjectId() async {
    if (_cached != null) return _cached!.isEmpty ? null : _cached;
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_favKey);
    _cached = id ?? '';
    return id;
  }

  /// Establece un proyecto como favorito (reemplaza el anterior)
  static Future<void> setFavorite(String projectId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_favKey, projectId);
    _cached = projectId;

    // Sincronizar con la API
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'projectId': projectId}),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to sync favorite with server');
      }
    } catch (e) {
      print('Error syncing favorite: $e');
    }
  }

  /// Elimina el favorito
  static Future<void> removeFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favKey);
    _cached = '';

    // Sincronizar con la API
    try {
      final response = await http.delete(Uri.parse(_apiUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to remove favorite from server');
      }
    } catch (e) {
      print('Error removing favorite: $e');
    }
  }

  /// Verifica si un proyecto es el favorito
  static Future<bool> isFavorite(String projectId) async {
    final favId = await getFavoriteProjectId();
    return favId == projectId;
  }
}
