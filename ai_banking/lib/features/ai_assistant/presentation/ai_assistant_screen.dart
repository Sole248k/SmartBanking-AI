import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/constants/app_constants.dart';
import '../providers/ai_providers.dart';
import 'widgets/chat_bubble.dart';

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(aiChatControllerProvider);
    final theme = Theme.of(context);

    // Scroll to bottom whenever messages change
    ref.listen(aiChatControllerProvider, (previous, next) {
      _scrollToBottom();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, size: 20),
            SizedBox(width: AppConstants.sm),
            Text('SmartBank AI'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => ref.read(aiChatControllerProvider.notifier).clearChat(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: AppConstants.screenPadding,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: messages[index]);
              },
            ),
          ),
          _buildQuickPrompts(),
          _buildInputArea(theme),
        ],
      ),
    );
  }

  Widget _buildQuickPrompts() {
    final prompts = [
      'Show my balance',
      'Analyze spending',
      'Saving advice',
    ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.md),
        itemCount: prompts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: AppConstants.sm),
            child: ActionChip(
              label: Text(prompts[index]),
              onPressed: () {
                ref.read(aiChatControllerProvider.notifier).sendMessage(prompts[index]);
              },
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMax),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Ask me anything...',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.lg,
                    vertical: AppConstants.md,
                  ),
                ),
                onSubmitted: (val) => _handleSend(),
              ),
            ),
            const SizedBox(width: AppConstants.sm),
            IconButton.filled(
              onPressed: _handleSend,
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSend() {
    if (_controller.text.trim().isNotEmpty) {
      ref.read(aiChatControllerProvider.notifier).sendMessage(_controller.text.trim());
      _controller.clear();
    }
  }
}
