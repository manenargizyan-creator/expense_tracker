import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  final http.Client _client;

  ApiClient({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  Uri _buildUri(String path) {
    final normalizedBase = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';

    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;

    return Uri.parse(normalizedBase).resolve(normalizedPath);
  }

  Future<dynamic> get(String path) async {
    final response = await _client.get(
      _buildUri(path),
      headers: {'Accept': 'application/json'},
    );

    return _handleResponse(response);
  }

  Future<dynamic> post(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final response = await _client.post(
      _buildUri(path),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Future<dynamic> put(String path, {required Map<String, dynamic> body}) async {
    final response = await _client.put(
      _buildUri(path),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Future<void> delete(String path) async {
    final response = await _client.delete(
      _buildUri(path),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'Հարցումը ձախողվեց։ Կոդ՝ ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'Սերվերի սխալ։ Կոդ՝ ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    if (response.body.isEmpty) return null;

    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const ApiException('Սերվերի պատասխանը վավեր JSON չէ։');
    }
  }

  void close() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
