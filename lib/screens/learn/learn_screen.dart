import 'package:flutter/material.dart';

import '../../content/learn_topics.dart';
import '../../theme.dart';
import '../../widgets/logo.dart';
import '../../widgets/seal_badge.dart';
import 'learn_detail_screen.dart';

/// Page 12: PMOS Health Education topic list with search.
class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final topics = [
      for (final t in learnTopics)
        if (q.isEmpty ||
            t.title.toLowerCase().contains(q) ||
            t.subtitle.toLowerCase().contains(q))
          t,
    ];
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: c, width: 1.4),
    );
    return Column(
      children: [
        const LogoHeader(),
        const SizedBox(height: 16),
        Text(
          'PMOS\nHEALTH EDUCATION',
          textAlign: TextAlign.center,
          style: displayStyle.copyWith(fontSize: 30),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              color: AppColors.aqua,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Search',
                      fillColor: const Color(0xFFF4F4F4),
                      suffixIcon: const Icon(Icons.search),
                      suffixIconColor: const Color(0xFF3B82C4),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      enabledBorder: border(const Color(0xFF3B82C4)),
                      focusedBorder: border(AppColors.deepTeal),
                    ),
                  ),
                ),
                Expanded(
                  child: topics.isEmpty
                      ? const Center(
                          child: Text(
                            'No topics found',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        )
                      : Scrollbar(
                          thumbVisibility: true,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                            itemCount: topics.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) =>
                                _TopicCard(topic: topics[i]),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic});

  final LearnTopic topic;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => LearnDetailScreen(topic: topic)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 10, 18),
          child: Column(
            children: [
              Text(
                topic.title,
                textAlign: TextAlign.center,
                style: displayStyle.copyWith(fontSize: 19),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  SealBadge(icon: topic.icon),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      topic.subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    size: 34,
                    color: AppColors.ink,
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
