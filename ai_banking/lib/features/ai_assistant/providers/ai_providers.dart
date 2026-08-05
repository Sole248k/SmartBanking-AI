import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/network/gemini_client.dart';
import '../../dashboard/providers/active_account_provider.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../analytics/providers/analytics_providers.dart';
import '../data/gemini_ai_repository_impl.dart';
import '../models/chat_message.dart';
import '../repositories/ai_repository.dart';

part 'ai_providers.g.dart';

@riverpod
AiRepository aiRepository(AiRepositoryRef ref) {
  final model = ref.watch(geminiClientProvider);
  return GeminiAiRepositoryImpl(model);
}

@riverpod
class AiChatController extends _$AiChatController {
  @override
  List<ChatMessage> build() {
    return [
      ChatMessage(
        id: 'initial',
        role: MessageRole.assistant,
        content: "Hello! I'm your SmartBank AI assistant. How can I help you with your finances today?",
        timestamp: DateTime.now(),
      ),
    ];
  }

  Future<void> sendMessage(String content) async {
    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      role: MessageRole.user,
      content: content,
      timestamp: DateTime.now(),
    );

    state = [...state, userMessage];

    final assistantMessageId = const Uuid().v4();
    final assistantMessage = ChatMessage(
      id: assistantMessageId,
      role: MessageRole.assistant,
      content: '',
      timestamp: DateTime.now(),
      isStreaming: true,
    );

    state = [...state, assistantMessage];

    // Gather live context
    final accounts = ref.read(dashboardAccountsProvider).value ?? [];
    final activeAccount = ref.read(activeAccountProvider);
    final report = ref.read(spendingReportControllerProvider).value;
    final transactions = ref.read(recentTransactionsProvider).value ?? [];

    final context = {
      'activeAccount': activeAccount?.toJson(),
      'allAccounts': accounts.map((e) => e.toJson()).toList(),
      'totalSpentThisMonth': report?.totalSpent ?? 0.0,
      'totalIncomeThisMonth': report?.totalIncome ?? 0.0,
      'categoryBreakdown': report?.categoryBreakdown ?? {},
      'recentTransactions': transactions.take(10).map((e) => {
        'title': e.title,
        'amount': e.amount,
        'type': e.type.name,
        'category': e.category,
        'date': e.date.toIso8601String(),
      }).toList(),
    };

    String fullResponse = '';
    final stream = ref.read(aiRepositoryProvider).getStreamingResponse(content, context);

    await for (final chunk in stream) {
      fullResponse += chunk;
      state = [
        for (final msg in state)
          if (msg.id == assistantMessageId)
            msg.copyWith(content: fullResponse)
          else
            msg
      ];
    }

    state = [
      for (final msg in state)
        if (msg.id == assistantMessageId)
          msg.copyWith(isStreaming: false)
        else
          msg
    ];
  }

  void clearChat() {
    state = build();
  }
}
