import 'package:flutter/material.dart';

enum LegalDocumentType { privacy, terms }

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    super.key,
    required this.type,
  });

  final LegalDocumentType type;

  @override
  Widget build(BuildContext context) {
    final isPrivacy = type == LegalDocumentType.privacy;
    final title = isPrivacy ? 'Privacy Policy' : 'Terms & Conditions';
    final sections = isPrivacy ? _privacySections : _termsSections;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: const BackButton(),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        itemCount: sections.length,
        separatorBuilder: (_, index) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          final section = sections[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.$1,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                section.$2,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                    ),
              ),
            ],
          );
        },
      ),
    );
  }

  static const _privacySections = <(String, String)>[
    (
      'Information we collect',
      'FloraMind AI may store account details, plant searches, saved preferences, and content you choose to submit so the app can provide its features.',
    ),
    (
      'How we use information',
      'We use this information to authenticate you, save your garden activity, improve recommendations, and respond to support requests.',
    ),
    (
      'Your choices',
      'You can update your profile, change your password, change app preferences, or contact support about your account data.',
    ),
    (
      'Security',
      'Account authentication is handled through Firebase Authentication. Never share your password or private API keys with anyone.',
    ),
  ];

  static const _termsSections = <(String, String)>[
    (
      'Using FloraMind AI',
      'Use the app responsibly and provide accurate information when requesting plant care or gardening recommendations.',
    ),
    (
      'Recommendations',
      'Plant identification, disease suggestions, and care guidance are informational. Always verify important treatment decisions with a qualified local expert and product label.',
    ),
    (
      'Your account',
      'You are responsible for keeping your login details secure and for activity performed through your account.',
    ),
    (
      'Availability',
      'Some features depend on internet connectivity, third-party services, device permissions, and backend availability.',
    ),
  ];
}
