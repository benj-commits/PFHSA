import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  static const _tokenKey = 'pfhsa_token';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final cleanQuery = query?.map((k, v) => MapEntry(k, v.toString()));
    return Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: cleanQuery);
  }

  dynamic _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    final message = body is Map && body['error'] != null ? body['error'] : 'Request failed.';
    throw ApiException(message);
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query, bool auth = true}) async {
    final response = await http.get(_uri(path, query), headers: await _headers(auth: auth));
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, Map<String, dynamic> data, {bool auth = true}) async {
    final response = await http.post(_uri(path), headers: await _headers(auth: auth), body: jsonEncode(data));
    return _handleResponse(response);
  }

  Future<dynamic> put(String path, Map<String, dynamic> data, {bool auth = true}) async {
    final response = await http.put(_uri(path), headers: await _headers(auth: auth), body: jsonEncode(data));
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path, {bool auth = true}) async {
    final response = await http.delete(_uri(path), headers: await _headers(auth: auth));
    return _handleResponse(response);
  }
}
