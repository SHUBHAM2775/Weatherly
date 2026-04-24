import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/services/groq_service.dart';

void main() {
  test('GroqService returns a suggestion', () async {
    final suggestion = await GroqService.getSuggestion(
      weatherCode: 0, // Clear sky
      humidity: 50,
      aqi: 80,
      city: 'Mumbai',
    );
    print('Groq suggestion: $suggestion');
    expect(suggestion, isNotEmpty);
  });
}
