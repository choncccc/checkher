import 'package:flutter/material.dart';

import '../../content/care_topics.dart';
import '../../theme.dart';
import '../../widgets/logo.dart';

/// Pages 6–11: a single Guided Self-Care article.
class CareDetailScreen extends StatelessWidget {
  const CareDetailScreen({super.key, required this.topic});

  final CareTopic topic;

  @override
  Widget build(BuildContext context) {
    const body = TextStyle(
      fontSize: 14.5,
      fontWeight: FontWeight.w500,
      height: 1.55,
    );
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const LogoHeader(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: PillTitle(topic.title),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                  decoration: const BoxDecoration(
                    color: AppColors.aqua,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(18, 18, 22, 24),
                        children: [
                          for (final b in topic.blocks)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: 10,
                                top: b.bold ? 6 : 0,
                              ),
                              child: b.bullet
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(
                                            top: 8,
                                            right: 10,
                                          ),
                                          child: CircleAvatar(
                                            radius: 3.5,
                                            backgroundColor: AppColors.deepTeal,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            b.text,
                                            style: body,
                                            textAlign: TextAlign.justify,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      b.text,
                                      style: b.bold
                                          ? body.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.deepTeal,
                                            )
                                          : body,
                                      textAlign: TextAlign.justify,
                                    ),
                            ),
                        ],
                      ),
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
