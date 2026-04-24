// groq_service.dart
// Handles calls to the Groq LLM API for dynamic AI suggestions.
// Paste your Groq API key below where indicated.

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GroqService {
  static String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';
  static const int _maxWords = 18;

  /// Fetches a dynamic suggestion from Groq based on weather and AQI.
  static Future<String> getSuggestion({
    required int weatherCode,
    required int humidity,
    required int? aqi,
    String city = '',
  }) async {
    final prompt = _buildPrompt(weatherCode, humidity, aqi, city);
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'llama-3.1-8b-instant', // Updated to supported Groq model
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a weather assistant. Return exactly one practical daily tip in very simple English. Keep it very short: max 18 words, no bullets, no quotes, no emojis, no difficult words.'
          },
          {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 30,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final suggestion = data['choices'][0]['message']['content'] as String?;
        return _shortenSuggestion(
          _simplifyWords(suggestion ?? 'Stay safe and check weather updates.'));
    } else {
      // Debug: print the error response for troubleshooting
      print('Groq API error: Status ${response.statusCode}');
      print('Groq API response: ${response.body}');
      return 'Stay safe and check weather updates.';
    }
  }

  /// Fetches an AQI-focused suggestion for the Air section.
  static Future<String> getAqiSuggestion({
    required int aqi,
    required int humidity,
    String city = '',
  }) async {
    final prompt =
        'City: $city\nAQI: $aqi\nHumidity: $humidity\nGive one very short AQI-focused health tip for today.';

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'llama-3.1-8b-instant',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are an air-quality assistant. Return exactly one AQI safety tip in very simple English, max 16 words, no bullets, no quotes, no emojis, no difficult words.'
          },
          {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 24,
        'temperature': 0.5,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final suggestion = data['choices'][0]['message']['content'] as String?;
        return _shortenSuggestion(_simplifyWords(
          suggestion ?? 'Limit outdoor exposure when air quality is poor.'));
    } else {
      print('Groq API error: Status ${response.statusCode}');
      print('Groq API response: ${response.body}');
      return 'Limit outdoor exposure when air quality is poor.';
    }
  }

  static String _buildPrompt(
      int weatherCode, int humidity, int? aqi, String city) {
    return 'City: $city\nWeather code: $weatherCode\nHumidity: $humidity\nAQI: ${aqi ?? 'unknown'}\nGive one practical outdoor/health tip for right now.';
  }

  static String _shortenSuggestion(String raw) {
    final cleaned = raw.replaceAll('\n', ' ').replaceAll('"', '').trim();
    final words = cleaned.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.length <= _maxWords) return cleaned;
    return '${words.take(_maxWords).join(' ')}...';
  }

  static String _simplifyWords(String text) {
    return text
        .replaceAll(RegExp(r'\bstrenuous\b', caseSensitive: false), 'hard')
        .replaceAll(RegExp(r'\bminimize\b', caseSensitive: false), 'reduce')
        .replaceAll(RegExp(r'\bprolonged\b', caseSensitive: false), 'long')
        .replaceAll(RegExp(r'\bexposure\b', caseSensitive: false), 'time outside')
        .replaceAll(RegExp(r'\brespiratory\b', caseSensitive: false), 'breathing')
        .replaceAll(RegExp(r'\bvulnerable\b', caseSensitive: false), 'sensitive')
        .trim();
  }
}
