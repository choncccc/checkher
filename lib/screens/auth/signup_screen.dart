import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/auth_repository.dart';
import '../../data/services.dart';
import '../../theme.dart';
import '../assessment/assessment_onboarding_screen.dart';
import '../main_shell.dart';
import 'auth_scaffold.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _address = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _dateFocus = FocusNode();
  DateTime? _lastPeriod;
  bool _busy = false;

  @override
  void dispose() {
    _dateFocus.dispose();
    for (final c in [_name, _username, _address, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _check(void Function() validate) {
    try {
      validate();
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  Future<void> _pickPeriodDate() async {
    // Move focus onto the tile so that when the picker closes, focus returns
    // here instead of to a text field (which would reopen the keyboard over
    // the Sign Up button).
    _dateFocus.requestFocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastPeriod ?? now,
      firstDate: now.subtract(const Duration(days: 120)),
      lastDate: now,
      helpText: 'First day of your last period',
    );
    if (picked != null) setState(() => _lastPeriod = picked);
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final user = await Services.of(context).auth.signUp(
        username: _username.text,
        displayName: _name.text,
        password: _password.text,
        address: _address.text,
        lastPeriodStart: _lastPeriod,
      );
      if (!mounted) return;
      final nav = Navigator.of(context);
      void enterApp() => nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => MainShell(user: user)),
        (_) => false,
      );
      // New users get the optional risk assessment first.
      nav.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) =>
              AssessmentOnboardingScreen(userId: user.id, onDone: enterApp),
        ),
        (_) => false,
      );
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 14);
    String? required(String? v, String msg) =>
        v == null || v.trim().isEmpty ? msg : null;
    return AuthScaffold(
      title: 'Create Account',
      subtitle: 'Your data stays private on this device',
      logoHeight: 96,
      showBack: true,
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Full Name',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (v) => required(v, 'Please enter your name.'),
              ),
              gap,
              TextFormField(
                controller: _username,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Username',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => _check(
                  () => AuthRepository.validateUsername((v ?? '').trim()),
                ),
              ),
              gap,
              TextFormField(
                controller: _address,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.streetAddress,
                decoration: const InputDecoration(
                  hintText: 'Address',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
                validator: (v) => required(v, 'Please enter your address.'),
              ),
              gap,
              PasswordField(
                controller: _password,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    _check(() => AuthRepository.validatePassword(v ?? '')),
              ),
              gap,
              PasswordField(
                controller: _confirm,
                hint: 'Confirm Password',
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _signUp(),
                validator: (v) =>
                    v != _password.text ? 'Passwords do not match.' : null,
              ),
              gap,
              _PeriodDateTile(
                date: _lastPeriod,
                focusNode: _dateFocus,
                onTap: _pickPeriodDate,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PillButton(label: 'Sign Up', onPressed: _signUp, busy: _busy),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text.rich(
            TextSpan(
              text: 'Already have an account? ',
              style: TextStyle(color: AppColors.inkSoft),
              children: [
                TextSpan(
                  text: 'Login',
                  style: TextStyle(
                    color: AppColors.deepTeal,
                    fontWeight: FontWeight.w800,
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

class _PeriodDateTile extends StatelessWidget {
  const _PeriodDateTile({
    required this.date,
    required this.focusNode,
    required this.onTap,
  });

  final DateTime? date;
  final FocusNode focusNode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final d = date;
    return Material(
      color: AppColors.mint,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        focusNode: focusNode,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.water_drop, color: AppColors.periodRed),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'First day of last period',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      d == null
                          ? 'Optional — helps track your cycle day'
                          : DateFormat.yMMMMd().format(d),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.calendar_month, color: AppColors.deepTeal),
            ],
          ),
        ),
      ),
    );
  }
}
