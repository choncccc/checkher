import 'package:flutter/material.dart';

import '../../content/care_topics.dart';
import '../../theme.dart';
import '../../widgets/logo.dart';
import 'care_detail_screen.dart';

/// Page 5: Guided Self-Care topic list.
class CareScreen extends StatelessWidget {
  const CareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const LogoHeader(),
        const SizedBox(height: 16),
        const PillTitle('Guided Self-Care'),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              color: AppColors.aqua,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: ListView.separated(
              padding: const EdgeInsets.all(14),
              itemCount: careTopics.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _TopicCard(topic: careTopics[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic});

  final CareTopic topic;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CareDetailScreen(topic: topic)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFF3FD9C4),
                child: Icon(topic.icon, color: AppColors.ink, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      style: displayStyle.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      topic.subtitle,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.aqua,
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.deepTeal,
                  size: 34,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
