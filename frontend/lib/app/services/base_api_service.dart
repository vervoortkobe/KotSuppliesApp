import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:kotsupplies/app/constants/app_constants.dart';

/// Base service class that provides common HTTP methods for API communication
abstract class BaseApiService {
  /// Sends a POST request with JSON body
  Future<http.Response> postJson(String path, Map<String, dynamic> body) async {
    return await http.post(
      Uri.parse('$kApiBaseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
  }

  /// Sends a PUT request with JSON body
  Future<http.Response> putJson(String path, Map<String, dynamic> body) async {
    return await http.put(
      Uri.parse('$kApiBaseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
  }

  /// Sends a GET request
  Future<http.Response> get(String path) async {
    return await http.get(Uri.parse('$kApiBaseUrl$path'));
  }

  /// Sends a DELETE request
  Future<http.Response> delete(String path) async {
    return await http.delete(Uri.parse('$kApiBaseUrl$path'));
  }

  /// Sends a POST request with multipart/form-data (for file uploads)
  Future<http.Response> postMultipart(
    String path,
    Map<String, String> fields, {
    File? file,
    String? fileFieldName,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse('$kApiBaseUrl$path'));
    request.fields.addAll(fields);
    if (file != null && fileFieldName != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          fileFieldName,
          file.path,
          contentType: MediaType('image', file.path.split('.').last),
        ),
      );
    }
    var response = await request.send();
    return http.Response.fromStream(response);
  }

  /// Sends a PUT request with multipart/form-data (for file uploads)
  Future<http.Response> putMultipart(
    String path,
    Map<String, String> fields, {
    File? file,
    String? fileFieldName,
  }) async {
    var request = http.MultipartRequest('PUT', Uri.parse('$kApiBaseUrl$path'));
    request.fields.addAll(fields);
    if (file != null && fileFieldName != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          fileFieldName,
          file.path,
          contentType: MediaType('image', file.path.split('.').last),
        ),
      );
    }
    var response = await request.send();
    return http.Response.fromStream(response);
  }

  /// Helper method to handle JSON response parsing
  T parseJsonResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
    String errorMessage,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return fromJson(json.decode(response.body));
    } else {
      throw Exception('$errorMessage: ${response.body}');
    }
  }

  /// Helper method to handle JSON list response parsing
  List<T> parseJsonListResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
    String errorMessage,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      Iterable l = json.decode(response.body);
      return List<T>.from(l.map((model) => fromJson(model)));
    } else {
      throw Exception('$errorMessage: ${response.body}');
    }
  }

  /// Helper method to handle void responses
  void handleVoidResponse(http.Response response, String errorMessage) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('$errorMessage: ${response.body}');
    }
  }
}
