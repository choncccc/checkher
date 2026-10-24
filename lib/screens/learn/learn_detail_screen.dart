import 'package:flutter/material.dart';

import '../../content/learn_topics.dart';
import '../../theme.dart';
import '../../widgets/logo.dart';

/// A single PMOS Health Education article. Content is still to come.
class LearnDetailScreen extends StatelessWidget {
  const LearnDetailScreen({super.key, required this.topic});

  final LearnTopic topic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const LogoHeader(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: PillTitle(topic.title, fontSize: 22),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                  decoration: const BoxDecoration(
                    color: AppColors.aqua,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 34,
                            backgroundColor: const Color(0xFF3FD9C4),
                            child: Icon(
                              topic.icon,
                              size: 34,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          topic.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.deepTeal,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Divider(color: AppColors.aquaSoft),
                        const SizedBox(height: 40),
                        // w
                        const Text(
                          'Content coming soon',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SafeArea(
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
