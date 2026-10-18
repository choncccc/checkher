import 'package:flutter/material.dart';

import '../../data/auth_repository.dart';
import '../../data/services.dart';
import 'auth_scaffold.dart';

/// Offline password reset: confirm the username together with the address
/// given at sign-up, then choose a new password.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _address = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_username, _address, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _reset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await Services.of(context).auth.resetPassword(
        username: _username.text,
        address: _address.text,
        newPassword: _password.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated. You can log in now.')),
      );
      Navigator.of(context).pop();
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
      title: 'Reset Password',
      subtitle: 'Enter your username and the address you signed up with',
      logoHeight: 96,
      showBack: true,
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _username,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Username',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => required(v, 'Enter your username'),
              ),
              gap,
              TextFormField(
                controller: _address,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.streetAddress,
                decoration: const InputDecoration(
                  hintText: 'Address',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
                validator: (v) => required(v, 'Enter your address'),
              ),
              gap,
              PasswordField(
                controller: _password,
                hint: 'New Password',
                textInputAction: TextInputAction.next,
                validator: (v) {
                  try {
                    AuthRepository.validatePassword(v ?? '');
                    return null;
                  } on AuthException catch (e) {
                    return e.message;
                  }
                },
              ),
              gap,
              PasswordField(
                controller: _confirm,
                hint: 'Confirm New Password',
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _reset(),
                validator: (v) =>
                    v != _password.text ? 'Passwords do not match.' : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PillButton(label: 'Reset Password', onPressed: _reset, busy: _busy),
      ],
    );
  }
}
