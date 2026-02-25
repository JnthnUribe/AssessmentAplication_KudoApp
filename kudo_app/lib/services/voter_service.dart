import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para generar y persistir el ID único del votante
class VoterService {
  static const String _voterIdKey = 'kudo_voter_id';
  static String? _cachedVoterId;

  /// Obtiene el voterId. Si no existe, genera uno nuevo y lo guarda.
  static Future<String> getVoterId() async {
    if (_cachedVoterId != null) return _cachedVoterId!;

    final prefs = await SharedPreferences.getInstance();
    var voterId = prefs.getString(_voterIdKey);

    if (voterId == null) {
      voterId = const Uuid().v4();
      await prefs.setString(_voterIdKey, voterId);
    }

    _cachedVoterId = voterId;
    return voterId;
  }
}
