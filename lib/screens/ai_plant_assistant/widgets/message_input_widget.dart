import 'dart:ui';

import 'package:flutter/material.dart';

class MessageInputWidget extends StatelessWidget {
  const MessageInputWidget({
    super.key,
    required this.controller,
    required this.onSendPressed,
    required this.onVoicePressed,
    required this.onImagePressed,
  });

  final TextEditingController controller;
  final VoidCallback onSendPressed;
  final VoidCallback onVoicePressed;
  final VoidCallback onImagePressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.26),
              width: 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.88),
                colorScheme.primary.withValues(alpha: 0.05),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1F4C2B).withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Type your gardening question...',
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.edit_note_rounded,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: onVoicePressed,
                    icon: const Icon(Icons.mic_rounded),
                    tooltip: 'Voice input',
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: onImagePressed,
                    icon: const Icon(Icons.image_rounded),
                    tooltip: 'Image upload',
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: onSendPressed,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Send'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(120, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
