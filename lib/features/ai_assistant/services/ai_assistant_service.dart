
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AiAssistantService {
  AiAssistantService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<String> askQuestion(String question) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('Please sign in to use the AI assistant.');
    }

    if (question.trim().isEmpty) {
      throw ArgumentError('Please enter a question.');
    }

    final token = await user.getIdToken();

    final response = await _client
        .post(
      Uri.parse('$baseUrl/api/ai-assistant'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'question': question.trim(),
      }),
    )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint('AI assistant error: ${response.statusCode}');
      throw Exception('Unable to get an AI response. Please try again.');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic> ||
        decoded['answer'] is! String ||
        (decoded['answer'] as String).trim().isEmpty) {
      throw const FormatException(
        'The AI backend returned an invalid response.',
      );
    }

    return (decoded['answer'] as String).trim();
  }

  void dispose() {
    _client.close();
  }
}
