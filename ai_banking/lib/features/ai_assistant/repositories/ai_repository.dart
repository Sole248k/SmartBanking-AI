import '../models/chat_message.dart';

abstract class AiRepository {
  Stream<String> getStreamingResponse(String prompt, Map<String, dynamic> context);
  Future<List<ChatMessage>> getChatHistory();
}
