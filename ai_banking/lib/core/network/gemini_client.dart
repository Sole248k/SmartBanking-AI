import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gemini_client.g.dart';

// IMPORTANT: Replace with your actual Gemini API Key from Google AI Studio
const _geminiApiKey = 'AQ.Ab8RN6J0whuMvWdFfe9cwF4UAcPIclWPreuLh2OYWYk9SkmdwA';

@riverpod
GenerativeModel geminiClient(GeminiClientRef ref) {
  return GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: _geminiApiKey,
  );
}
