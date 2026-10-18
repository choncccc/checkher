import 'package:flutter/material.dart';

import '../theme.dart';

/// Page 13: the sidebar opened from the Menu tab or by swiping in from the
/// left edge.
class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key, required this.onSelect});

  final ValueChanged<String> onSelect;

  static const items = [
    'PMOS Risk Assessment',
    'Emergency Signs',
    'Nearby Health Services',
    'Supplement Reminder',
    'Meal Guide',
    'Exercise Library',
    'Notifications & Reminders',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * 0.74;
    return Padding(
      // Sits below the logo, as in the layout.
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + 72),
      child: SizedBox(
        width: width,
        child: Material(
          color: const Color(0xFFFDF4F2),
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Color(0xFF3FD9C4), width: 1.5),
            borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 36, 20, 24),
            children: [
              Text(
                'MENU',
                textAlign: TextAlign.center,
                style: displayStyle.copyWith(fontSize: 30),
              ),
              const SizedBox(height: 22),
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: AppColors.aqua,
                    borderRadius: BorderRadius.circular(30),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () => onSelect(item),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Text(
                          item,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
