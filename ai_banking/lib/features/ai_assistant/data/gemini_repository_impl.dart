import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../core/network/env.dart';
import '../models/chat_message.dart';
import '../repositories/ai_repository.dart';

class GeminiRepositoryImpl implements AiRepository {
  final GenerativeModel _model;

  GeminiRepositoryImpl(this._model);

  @override
  Stream<String> getStreamingResponse(String prompt, Map<String, dynamic> context) async* {
    final systemPrompt = _buildSystemPrompt(context);
    
    // The "Gold Standard" for providing system context to an existing model instance 
    // is to start a chat with the system instruction in the history.
    final chat = _model.startChat(
      history: [
        Content.system(systemPrompt),
      ],
    );

    try {
      final responseStream = chat.sendMessageStream(Content.text(prompt));
      
      await for (final chunk in responseStream) {
        final text = chunk.text;
        if (text != null) {
          yield text;
        }
      }
    } catch (e) {
      // If streaming is specifically blocked, try a non-streaming fallback
      if (e.toString().contains('blocked') || e.toString().contains('StreamGenerateContent')) {
        print('[GeminiRepo] Streaming blocked, attempting non-streaming fallback...');
        try {
          final response = await chat.sendMessage(Content.text(prompt));
          final text = response.text;
          if (text != null) {
            yield text;
            return;
          }
        } catch (fallbackError) {
          throw 'AI Error (Fallback failed): $fallbackError';
        }
      }

      if (e.toString().contains('401') || e.toString().contains('403')) {
        throw 'Authentication Failed. Please ensure your API key is valid and you have run the build command. Error: $e';
      }
      throw 'AI Error: $e';
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
