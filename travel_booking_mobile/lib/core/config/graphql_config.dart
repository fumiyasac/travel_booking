import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class GraphQLHttpClient {
  final String _baseUrl;
  final http.Client? _httpClient;

  GraphQLHttpClient({
    String? baseUrl,
    http.Client? client,
  })  : _baseUrl = baseUrl ??
            (Platform.isAndroid
                ? 'http://10.0.2.2:4000/graphql'
                : 'http://localhost:4000/graphql'),
        _httpClient = client;

  Future<Map<String, dynamic>> query({
    required String document,
    Map<String, dynamic>? variables,
  }) async {
    return _send(document: document, variables: variables);
  }

  Future<Map<String, dynamic>> mutate({
    required String document,
    Map<String, dynamic>? variables,
  }) async {
    return _send(document: document, variables: variables);
  }

  Future<Map<String, dynamic>> _send({
    required String document,
    Map<String, dynamic>? variables,
  }) async {
    final uri = Uri.parse(_baseUrl);
    final bodyJson = jsonEncode({
      'query': document,
      if (variables != null) 'variables': variables,
    });
    final bodyBytes = utf8.encode(bodyJson);

    // Use dart:io HttpClient directly to avoid IOClient keep-alive issues on iOS
    final ioClient = HttpClient();
    ioClient.connectionTimeout = const Duration(seconds: 30);
    try {
      final ioRequest = await ioClient.postUrl(uri);
      ioRequest.persistentConnection = false;
      ioRequest.headers.set('Content-Type', 'application/json; charset=utf-8');
      ioRequest.headers.set('apollo-require-preflight', 'true');
      ioRequest.headers.contentLength = bodyBytes.length;
      ioRequest.add(bodyBytes);

      final ioResponse = await ioRequest.close();
      final responseBody = await ioResponse.transform(utf8.decoder).join();

      if (ioResponse.statusCode != 200) {
        throw Exception('GraphQL request failed: ${ioResponse.statusCode}');
      }

      final body = jsonDecode(responseBody) as Map<String, dynamic>;
      if (body['errors'] != null) {
        final errors = body['errors'] as List<dynamic>;
        throw Exception(errors
            .map((e) => (e as Map<String, dynamic>)['message'])
            .join(', '));
      }

      return body['data'] as Map<String, dynamic>? ?? {};
    } finally {
      ioClient.close(force: false);
    }
  }

  void dispose() => _httpClient?.close();
}
