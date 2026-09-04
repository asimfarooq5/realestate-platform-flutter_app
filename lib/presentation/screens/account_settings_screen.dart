import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';
import 'package:malkiyat_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:malkiyat_app/presentation/screens/auth_landing_screen.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon')),
    );
  }

  Future<void> _editField(BuildContext context, {required String label, required String initialValue, required void Function(String) onSave}) async {
    final controller = TextEditingController(text: initialValue);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) onSave(result);
  }

  Future<void> _confirmDeactivate(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate account?'),
        content: const Text('Your account will be turned off and you\'ll be signed out. You can contact support to reactivate it later.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Deactivate', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(DeactivateAccountRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account settings')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AuthLandingScreen()),
              (route) => false,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is! Authenticated) return const SizedBox.shrink();
            final user = state.user;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionLabel('PERSONAL INFO'),
                _Card(children: [
                  _Row(
                    title: 'Name',
                    value: user.name ?? '—',
                    onTap: () => _editField(
                      context,
                      label: 'name',
                      initialValue: user.name ?? '',
                      onSave: (v) => context.read<AuthBloc>().add(UpdateProfileRequested(name: v)),
                    ),
                  ),
                  const Divider(height: 1),
                  _Row(title: 'Email', value: user.email, onTap: null),
                  const Divider(height: 1),
                  _Row(
                    title: 'Phone',
                    value: user.phone ?? '—',
                    onTap: () => _editField(
                      context,
                      label: 'phone',
                      initialValue: user.phone ?? '',
                      onSave: (v) => context.read<AuthBloc>().add(UpdateProfileRequested(phone: v)),
                    ),
                  ),
                  const Divider(height: 1),
                  _Row(title: 'Profile photo', value: 'Change photo', onTap: () => _comingSoon(context)),
                ]),
                const SizedBox(height: 20),
                _SectionLabel('PROFILE SETTINGS'),
                _Card(children: [
                  _Row(title: 'Notification settings', value: 'Choose which alerts you get', onTap: () => _comingSoon(context)),
                  const Divider(height: 1),
                  _Row(title: 'Privacy & preferences', value: 'Contact, location, messages', onTap: () => _comingSoon(context)),
                  const Divider(height: 1),
                  _Row(title: 'Security & password', value: null, onTap: () => _comingSoon(context)),
                ]),
                const SizedBox(height: 20),
                _SectionLabel('MANAGE ACCOUNT'),
                _Card(children: [
                  _Row(title: 'Privacy & cookies', value: 'Policy, clear app cache', onTap: () => _comingSoon(context)),
                  const Divider(height: 1),
                  _Row(
                    title: 'Deactivate account',
                    value: 'Temporarily turn off your account',
                    titleColor: Colors.red,
                    onTap: () => _confirmDeactivate(context),
                  ),
                ]),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 0.5)),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.hairline)),
      child: Column(children: children),
    );
  }
}

class _Row extends StatelessWidget {
  final String title;
  final String? value;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _Row({required this.title, this.value, this.titleColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: titleColor ?? AppTheme.textPrimary)),
      subtitle: value != null ? Text(value!, style: const TextStyle(fontSize: 12.5)) : null,
      trailing: onTap != null ? const Icon(Icons.chevron_right, color: AppTheme.textMuted) : null,
      onTap: onTap,
    );
  }
}
