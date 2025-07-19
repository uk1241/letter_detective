// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:letter_detective/models/letter_model.dart';

class ApiService {
  static const String _baseURL = 'http://13.60.220.96:8000';
  static const String _secretKey = 'uG7pK2aLxX9zR1MvWq3EoJfHdTYcBn84';

  static const String _hardcodedAuthToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9';

  static Future<String?> fetchAccessToken() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseURL/auth/v5/firebase/signin'),
        headers: {
          'Authorization': 'Bearer $_hardcodedAuthToken', // Using the provided token
          'x-secret-key': _secretKey,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['data']['accessToken'];
      } else {
        print('Failed to get access token. Status code: ${response.statusCode}, Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching access token: $e');
      return null;
    }
  }

  static Future<GameData?> fetchContent(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseURL/content/v5/sample-assets'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return GameData.fromJson(jsonData); // Use GameData
      } else {
        print('Failed to get content. Status code: ${response.statusCode}, Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching content: $e');
      return null;
    }
  }
}