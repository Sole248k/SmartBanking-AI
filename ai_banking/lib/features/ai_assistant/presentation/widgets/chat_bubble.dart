import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../app/constants/app_constants.dart';
import '../../models/chat_message.dart';

class ChatBubble extends StatelessWidget {

  const ChatBubble({super.key, required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final theme = Theme.of(context);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.md),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.md,
          vertical: AppConstants.sm,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: isUser 
            ? theme.colorScheme.primary 
            : (message.isError 
                ? theme.colorScheme.errorContainer.withValues(alpha: 0.5)
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppConstants.radiusLg),
            topRight: const Radius.circular(AppConstants.radiusLg),
            bottomLeft: Radius.circular(isUser ? AppConstants.radiusLg : 0),
            bottomRight: Radius.circular(isUser ? 0 : AppConstants.radiusLg),
          ),
          border: message.isError 
            ? Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)) 
            : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser && message.content.isEmpty && message.isStreaming)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: SpinKitThreeBounce(
                  color: Colors.grey,
                  size: 20,
                ),
              )
            else
              message.role == MessageRole.user
                  ? Text(
                      message.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.isError)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, size: 16, color: theme.colorScheme.error),
                                const SizedBox(width: 4),
                                Text(
                                  'AI Error',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        MarkdownBody(
                          data: message.content,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(
                              color: message.isError 
                                ? theme.colorScheme.error 
                                : theme.colorScheme.onSurface, 
                              fontSize: 15,
                            ),
                            strong: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: (isUser ? Colors.white70 : Colors.grey).withValues(alpha: 0.6),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
