import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _keyName = 'user_name';
  static const String _keyEmail = 'user_email';
  static const String _keyPhone = 'user_phone';

  /// Guarda los datos del usuario localmente (Login)
  static Future<void> saveUser({
    required String name,
    required String email,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPhone, phone);
  }

  /// Recupera los datos del usuario actual
  static Future<Map<String, String?>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyName),
      'email': prefs.getString(_keyEmail),
      'phone': prefs.getString(_keyPhone),
    };
  }

  /// Verifica si el usuario ya ha iniciado sesión
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyName) &&
        prefs.containsKey(_keyEmail) &&
        prefs.containsKey(_keyPhone);
  }

  /// Cierra sesión borrando los datos
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPhone);
  }

  /// Registra un nuevo usuario
  static Future<void> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    // Aquí puedes agregar lógica para enviar datos a la API o guardarlos localmente
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);
    await prefs.setString('user_password', password);
  }
}
