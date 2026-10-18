import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/services.dart';
import '../models/user.dart';
import '../theme.dart';
import '../widgets/logo.dart';
import 'auth/login_screen.dart';

/// Basic profile tab: account info, cycle settings and logout.
/// The designed "Me" layout comes later in the prototype.
class MeScreen extends StatelessWidget {
  const MeScreen({super.key, required this.user, required this.onUserChanged});

  final AppUser user;
  final ValueChanged<AppUser> onUserChanged;

  Future<void> _editPeriod(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: user.lastPeriodStart ?? now,
      firstDate: now.subtract(const Duration(days: 120)),
      lastDate: now,
      helpText: 'First day of your last period',
    );
    if (picked == null || !context.mounted) return;
    onUserChanged(
      await Services.of(
        context,
      ).auth.updateCycle(user, lastPeriodStart: picked),
    );
  }

  Future<void> _editLength(
    BuildContext context, {
    required String title,
    required int current,
    required int min,
    required int max,
    required bool isCycle,
  }) async {
    final value = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(title),
        children: [
          SizedBox(
            height: 300,
            width: 200,
            child: ListView(
              children: [
                for (var d = min; d <= max; d++)
                  ListTile(
                    title: Text('$d days'),
                    selected: d == current,
                    onTap: () => Navigator.pop(ctx, d),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (value == null || !context.mounted) return;
    final auth = Services.of(context).auth;
    onUserChanged(
      await auth.updateCycle(
        user,
        lastPeriodStart: user.lastPeriodStart ?? DateTime.now(),
        cycleLength: isCycle ? value : null,
        periodLength: isCycle ? null : value,
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await Services.of(context).auth.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final last = user.lastPeriodStart;
    return Column(
      children: [
        const LogoHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.aqua,
                child: Icon(Icons.person, size: 48, color: AppColors.ink),
              ),
              const SizedBox(height: 10),
              Text(
                user.displayName,
                textAlign: TextAlign.center,
                style: displayStyle.copyWith(fontSize: 22),
              ),
              Text(
                '@${user.username}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.inkSoft),
              ),
              const SizedBox(height: 20),
              Card(
                color: Colors.white,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.home_outlined),
                      title: const Text('Address'),
                      subtitle: Text(user.address),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: Colors.white,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.calendar_month),
                      title: const Text('Last period started'),
                      subtitle: Text(
                        last == null
                            ? 'Not set'
                            : DateFormat.yMMMd().format(last),
                      ),
                      onTap: () => _editPeriod(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.loop),
                      title: const Text('Cycle length'),
                      subtitle: Text('${user.cycleLength} days'),
                      onTap: () => _editLength(
                        context,
                        title: 'Cycle length',
                        current: user.cycleLength,
                        min: 20,
                        max: 45,
                        isCycle: true,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.water_drop),
                      title: const Text('Period length'),
                      subtitle: Text('${user.periodLength} days'),
                      onTap: () => _editLength(
                        context,
                        title: 'Period length',
                        current: user.periodLength,
                        min: 2,
                        max: 10,
                        isCycle: false,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: Colors.white,
                child: ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.periodRed),
                  title: const Text('Log out'),
                  onTap: () => _logout(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
