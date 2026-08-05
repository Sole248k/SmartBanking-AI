// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'dart:async';
import 'dart:convert';
import '../models/chat_message.dart';
import '../repositories/ai_repository.dart';

/// AI repository implementation using Puter.js (free, unlimited, no API key needed).
/// Works on Flutter Web only — requires Puter.js to be loaded in index.html.
class PuterRepositoryImpl implements AiRepository {
  @override
  Stream<String> getStreamingResponse(
      String prompt, Map<String, dynamic> context) async* {
    final controller = StreamController<String>();

    final fullPrompt = _buildFullPrompt(prompt, context);

    // JS callbacks bridged into Dart via js.allowInterop
    final chunkCb = js.allowInterop((String chunk) {
      if (!controller.isClosed) controller.add(chunk);
    });

    final doneCb = js.allowInterop(() {
      if (!controller.isClosed) controller.close();
    });

    final errorCb = js.allowInterop((String error) {
      if (!controller.isClosed) {
        controller.addError('AI Error: $error');
        controller.close();
      }
    });

    // Call the JS bridge function defined in index.html
    js.context.callMethod('puterChatStream', [fullPrompt, chunkCb, doneCb, errorCb]);

    yield* controller.stream;
  }

  String _buildFullPrompt(String userMessage, Map<String, dynamic> context) {
    return '''You are SmartBank AI, a highly intelligent and helpful financial assistant for a premium digital bank.
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

User Question: $userMessage''';
  }

  @override
  Future<List<ChatMessage>> getChatHistory() async => [];
}
