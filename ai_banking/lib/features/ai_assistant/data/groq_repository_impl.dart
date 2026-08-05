import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/network/env.dart';
import '../models/chat_message.dart';
import '../repositories/ai_repository.dart';

/// AI repository using Groq's free tier API.
/// - No end-user login required — the API key is embedded in the app.
/// - Free tier: 30 req/min, 14,400 req/day, 500,000 tokens/day.
/// - Model: llama-3.1-8b-instant (fast, free, capable).
/// - Get a free key at: https://console.groq.com
class GroqRepositoryImpl implements AiRepository {
  static const String _apiUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.1-8b-instant';

  final _client = http.Client();

  @override
  Stream<String> getStreamingResponse(
    String prompt,
    Map<String, dynamic> context,
  ) async* {
    final systemPrompt = _buildSystemPrompt(context);

    final request = http.Request('POST', Uri.parse(_apiUrl));
    request.headers['Authorization'] = 'Bearer ${Env.groqApiKey}';
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode({
      'model': _model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': prompt},
      ],
      'stream': true,
      'max_tokens': 1024,
    });

    print('[GroqAI] Requesting stream from Groq (model: $_model)...');

    final http.StreamedResponse response;
    try {
      response = await _client.send(request);
    } catch (e) {
      throw 'AI Error: Could not connect to Groq API. Check your internet connection. ($e)';
    }

    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      final decoded = jsonDecode(body);
      final message = decoded['error']?['message'] ?? body;
      throw 'AI Error (${response.statusCode}): $message';
    }

    // Parse SSE (Server-Sent Events) stream
    // Each chunk is: "data: {...json...}\n" or "data: [DONE]\n"
    final lineBuffer = StringBuffer();

    await for (final bytes in response.stream) {
      final text = utf8.decode(bytes);
      lineBuffer.write(text);
      final raw = lineBuffer.toString();
      final lines = raw.split('\n');

      // Process all complete lines; hold last potentially incomplete one
      for (int i = 0; i < lines.length - 1; i++) {
        final line = lines[i].trim();
        if (!line.startsWith('data: ')) continue;

        final data = line.substring(6).trim();
        if (data == '[DONE]') return;

        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final content =
              json['choices']?[0]?['delta']?['content'] as String?;
          if (content != null && content.isNotEmpty) {
            yield content;
          }
        } catch (_) {
          // Ignore malformed SSE chunks
        }
      }

      // Keep the incomplete last line for the next iteration
      lineBuffer
        ..clear()
        ..write(lines.last);
    }
  }

  String _buildSystemPrompt(Map<String, dynamic> context) {
    return '''You are SmartBank AI, a highly intelligent and helpful financial assistant for a premium digital bank.
You have access to the user\'s real-time financial data provided in JSON format below.

CONTEXT DATA:
${jsonEncode(context)}

INSTRUCTIONS:
1. Always assume the currency is Philippine Peso (₱) unless otherwise specified.
2. Use the provided data to answer questions about balances, spending, income, and transaction history.
3. Be professional, concise, and empathetic. Use Markdown for formatting (bold, lists, tables) to make info easy to read.
4. If a user asks about "my account", refer to the \'activeAccount\' provided in the context.
5. Provide actionable saving advice if the user\'s spending seems high in a specific category.
6. Do not mention technical details like Firestore IDs or JSON keys.
7. If data is missing or zero, acknowledge it politely instead of making up numbers.''';
  }

  @override
  Future<List<ChatMessage>> getChatHistory() async => [];
}
