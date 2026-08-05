import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/chat_message.dart';
import '../repositories/ai_repository.dart';

class GeminiRestRepositoryImpl implements AiRepository {
  final Dio _client;
  final String _model = 'gemini-2.0-flash-exp';

  GeminiRestRepositoryImpl(this._client);

  @override
  Stream<String> getStreamingResponse(String prompt, Map<String, dynamic> context) async* {
    final systemPrompt = _buildSystemPrompt(context);
    
    final payload = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": "$systemPrompt\n\nUser Question: $prompt"}
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.7,
        "topP": 0.95,
        "topK": 64,
        "maxOutputTokens": 2048,
        "responseMimeType": "text/plain",
      }
    };

    try {
      final response = await _client.post(
        '/models/$_model:streamGenerateContent?alt=sse',
        data: payload,
        options: Options(responseType: ResponseType.stream),
      );

      final Stream<List<int>> stream = response.data.stream;
      final transformer = utf8.decoder.fuse(const LineSplitter());
      
      await for (final line in stream.transform(transformer)) {
        if (line.startsWith('data: ')) {
          final jsonStr = line.substring(6);
          if (jsonStr == '[DONE]') break;
          
          try {
            final data = jsonDecode(jsonStr);
            final text = data['candidates']?[0]['content']['parts']?[0]['text'] as String?;
            if (text != null) {
              yield text;
            }
          } catch (e) {
            // Ignore non-json or malformed chunks in SSE stream
          }
        }
      }
    } on DioException catch (e) {
      final message = e.response?.data?['error']?['message'] ?? e.message;
      throw 'REST API Error: $message';
    } catch (e) {
      rethrow;
    }
  }

  String _buildSystemPrompt(Map<String, dynamic> context) {
    return '''
You are SmartBank AI, a highly intelligent and helpful financial assistant for a premium digital bank.
You have access to the user's real-time financial data provided in JSON format below.

CONTEXT DATA:
${jsonEncode(context)}

INSTRUCTIONS:
1. Always assume the currency is Philippine Peso (₱) unless otherwise specified.
2. Use the provided data to answer questions about balances, spending, income, and transaction history.
3. Be professional, concise, and empathetic. Use Markdown for formatting (bold, lists, tables) to make info easy to read.
4. If a user asks about "my account", refer to the 'activeAccount' provided in the context.
5. Provide actionable saving advice if the user's spending seems high in a specific category.
6. Do not mention technical details like Firestore IDs or JSON keys.
7. If data is missing or zero, acknowledge it politely instead of making up numbers.
''';
  }

  @override
  Future<List<ChatMessage>> getChatHistory() async {
    return [];
  }
}
