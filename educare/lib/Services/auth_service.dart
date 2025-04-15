import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String apiUrl =
      'http://localhost:8080/api/login'; // troque pelo endpoint real

  static Future<Map<String, dynamic>?> login(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'senha': senha,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Erro: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro no login: $e');
      return null;
    }
  }
}
