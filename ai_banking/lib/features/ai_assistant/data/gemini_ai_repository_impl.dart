import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/chat_message.dart';
import '../repositories/ai_repository.dart';

class GeminiAiRepositoryImpl implements AiRepository {

  GeminiAiRepositoryImpl(this._model);
  final GenerativeModel _model;

  @override
  Stream<String> getStreamingResponse(String prompt, Map<String, dynamic> context) async* {
    final systemPrompt = '''
You are SmartBank AI, a highly intelligent and helpful financial assistant for a premium digital bank.
You have access to the user's real-time financial data provided in JSON format below.

CONTEXT DATA:
${jsonEncode(context)}

INSTRUCTIONS:
1. Always assume the currency is Philippine Peso (₱) unless otherwise specified.
2. Use the provided data to answer questions about balances, spending, income, and transaction history.
3. Be professional, concise, and empathetic. Use Markdown for formatting (bold, lists, tables) to make info easy to read.
4. If a user asks about "my account", refer to the 'activeAccount' provided in the context.
5. Provide actionable saving advice if the user's spending seems high in a specific category. Mention their Savings Goals if relevant.
6. If the user asks about verification or security, inform them about our Identity Verification (KYC) process which uses advanced ML face detection.
7. Do not mention technical details like Firestore IDs or JSON keys.
8. If data is missing or zero, acknowledge it politely instead of making up numbers.
''';

    final fullPrompt = '$systemPrompt\n\nUser Question: $prompt';
    final content = [Content.text(fullPrompt)];
    
    final response = _model.generateContentStream(content);

    await for (final chunk in response) {
      if (chunk.text != null) {
        yield chunk.text!;
      }
    }
  }

  @override
  Future<List<ChatMessage>> getChatHistory() async {
    return [];
  }
}
