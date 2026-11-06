import 'package:flutter/material.dart';

import '../dashboard/widgets/dashboard_background.dart';
import '../../services/ai_plant_assistant_service.dart';
import '../disease_library/disease_library_screen.dart';
import '../fertilizer_recommendation/fertilizer_recommendation_screen.dart';
import '../cultivation_tips/cultivation_tips_screen.dart';
import 'widgets/ai_chat_bubble.dart';
import 'widgets/message_input_widget.dart';
import 'widgets/quick_action_card.dart';
import 'widgets/suggested_question_chip.dart';
import 'widgets/user_chat_bubble.dart';
import '../plant_detection/plant_detection_screen.dart';
import '../plant_recommendation/plant_recommendation_screen.dart';

class AIPlantAssistantScreen extends StatefulWidget {
  const AIPlantAssistantScreen({super.key});

  @override
  State<AIPlantAssistantScreen> createState() => _AIPlantAssistantScreenState();
}

class _AIPlantAssistantScreenState extends State<AIPlantAssistantScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final FirestoreAssistantService _assistantService =
      const FirestoreAssistantService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isResponding = false;
  int? _pendingAssistantMessageIndex;

  static const List<String> _suggestedQuestions = [
    'Which plant is best for my garden?',
    'Why are my leaves turning brown?',
    'Which fertilizer should I use?',
    'How often should I water my plants?',
    'How can I prevent diseases?',
  ];

  static const List<_QuickActionData> _quickActions = [
    _QuickActionData(
      title: 'Plant Care',
      icon: Icons.spa_rounded,
      accentColor: Color(0xFF2E7D32),
    ),
    _QuickActionData(
      title: 'Disease Help',
      icon: Icons.bug_report_rounded,
      accentColor: Color(0xFF43A047),
    ),
    _QuickActionData(
      title: 'Watering Advice',
      icon: Icons.water_drop_rounded,
      accentColor: Color(0xFF4C8BF5),
    ),
    _QuickActionData(
      title: 'Fertilizer Guide',
      icon: Icons.science_rounded,
      accentColor: Color(0xFFF4A261),
    ),
    _QuickActionData(
      title: 'Garden Tips',
      icon: Icons.local_florist_rounded,
      accentColor: Color(0xFF66BB6A),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _messages.add(
      const _ChatMessage(
        text:
            "Hello! I'm FloraMind AI. Ask me about plant care, diseases, watering, fertilizers, or garden tips and I'll look up the Firestore garden data.",
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage(String message) async {
    final text = message.trim();
    if (text.isEmpty || _isResponding) {
      return;
    }

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _messageController.clear();
      _messages.add(
        const _ChatMessage(text: '', isUser: false, isLoading: true),
      );
      _pendingAssistantMessageIndex = _messages.length - 1;
      _isResponding = true;
    });
    _scrollToBottom();

    try {
      final response = await _assistantService.answerQuestion(text);
      if (!mounted) {
        return;
      }
      setState(() {
        if (_pendingAssistantMessageIndex != null &&
            _pendingAssistantMessageIndex! < _messages.length) {
          _messages[_pendingAssistantMessageIndex!] = _ChatMessage(
            text: response.message,
            isUser: false,
          );
        }
        _pendingAssistantMessageIndex = null;
        _isResponding = false;
      });
    } on AssistantKnowledgeException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        if (_pendingAssistantMessageIndex != null &&
            _pendingAssistantMessageIndex! < _messages.length) {
          _messages[_pendingAssistantMessageIndex!] = _ChatMessage(
            text: error.message,
            isUser: false,
          );
        }
        _pendingAssistantMessageIndex = null;
        _isResponding = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        if (_pendingAssistantMessageIndex != null &&
            _pendingAssistantMessageIndex! < _messages.length) {
          _messages[_pendingAssistantMessageIndex!] = const _ChatMessage(
            text:
                'I could not fetch the Firestore garden data right now. Please try again in a moment.',
            isUser: false,
          );
        }
        _pendingAssistantMessageIndex = null;
        _isResponding = false;
      });
    }

    _scrollToBottom();
  }

  void _onSuggestedQuestionTap(String question) {
    _sendMessage(question);
  }

  void _onQuickActionTap(String title) {
    switch (title) {
      case 'Plant Care':
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const PlantDetectionScreen()),
        );
        return;
      case 'Disease Help':
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const DiseaseLibraryScreen()),
        );
        return;
      case 'Watering Advice':
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const CultivationTipsScreen(),
          ),
        );
        return;
      case 'Fertilizer Guide':
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const FertilizerRecommendationScreen(),
          ),
        );
        return;
      case 'Garden Tips':
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const PlantRecommendationScreen(),
          ),
        );
        return;
      default:
        _showSnackBar('$title is not connected yet');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('AI Plant Assistant'),
        centerTitle: false,
        backgroundColor: colorScheme.surface.withValues(alpha: 0.90),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: DashboardBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final contentWidth = width >= 1240
                    ? 1160.0
                    : width >= 920
                    ? 900.0
                    : width - 32;
                final quickActionColumns = width >= 1120
                    ? 3
                    : width >= 760
                    ? 2
                    : 1;
                final chatPanelHeight = width >= 900 ? 520.0 : 460.0;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentWidth),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Ask FloraMind AI any gardening question and receive intelligent guidance.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  height: 1.5,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 18),
                              const _SectionHeader(
                                title: 'Quick Actions',
                                subtitle:
                                    'Shortcuts for common gardening topics and future assistant tools.',
                              ),
                              const SizedBox(height: 16),
                              LayoutBuilder(
                                builder: (context, actionConstraints) {
                                  final gap = 14.0;
                                  final cardWidth = quickActionColumns == 1
                                      ? actionConstraints.maxWidth
                                      : ((actionConstraints.maxWidth -
                                                    ((quickActionColumns - 1) *
                                                        gap)) /
                                                quickActionColumns)
                                            .clamp(220.0, 360.0)
                                            .toDouble();

                                  return Wrap(
                                    spacing: gap,
                                    runSpacing: gap,
                                    children: _quickActions
                                        .map(
                                          (action) => SizedBox(
                                            width: cardWidth,
                                            child: QuickActionCard(
                                              title: action.title,
                                              icon: action.icon,
                                              accentColor: action.accentColor,
                                              onTap: () => _onQuickActionTap(
                                                action.title,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              const _SectionHeader(
                                title: 'Conversation',
                                subtitle:
                                    'Firestore-backed chat history and answers for gardening questions.',
                              ),
                              const SizedBox(height: 16),
                              _ChatPanel(
                                messages: _messages,
                                controller: _scrollController,
                                height: chatPanelHeight,
                              ),
                              const SizedBox(height: 16),
                              const _SectionHeader(
                                title: 'Suggested Questions',
                                subtitle:
                                    'Tap any question to insert it into the chat and receive a Firestore answer.',
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: _suggestedQuestions
                                    .map(
                                      (question) => SuggestedQuestionChip(
                                        label: question,
                                        onTap: () =>
                                            _onSuggestedQuestionTap(question),
                                      ),
                                    )
                                    .toList(),
                              ),
                              const SizedBox(height: 16),
                              MessageInputWidget(
                                controller: _messageController,
                                onSendPressed: () =>
                                    _sendMessage(_messageController.text),
                                onVoicePressed: () => _showSnackBar(
                                  'Voice input will be connected later',
                                ),
                                onImagePressed: () => _showSnackBar(
                                  'Image upload will be connected later',
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatPanel extends StatelessWidget {
  const _ChatPanel({
    required this.messages,
    required this.controller,
    required this.height,
  });

  final List<_ChatMessage> messages;
  final ScrollController controller;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.26),
            width: 1,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.86),
              colorScheme.primary.withValues(alpha: 0.05),
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1F4C2B).withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ListView.separated(
          controller: controller,
          padding: const EdgeInsets.all(18),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final message = messages[index];
            if (message.isLoading) {
              return const _LoadingChatBubble();
            }
            return message.isUser
                ? UserChatBubble(message: message.text)
                : AIChatBubble(message: message.text);
          },
          separatorBuilder: (context, _) => const SizedBox(height: 12),
          itemCount: messages.length,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.isLoading = false,
  });

  final String text;
  final bool isUser;
  final bool isLoading;
}

class _LoadingChatBubble extends StatelessWidget {
  const _LoadingChatBubble();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.24),
                width: 1,
              ),
              color: Colors.white.withValues(alpha: 0.88),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1F4C2B).withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary.withValues(alpha: 0.12),
                  ),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Searching Firestore...',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.title,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final IconData icon;
  final Color accentColor;
}
