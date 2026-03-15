import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final theme  = context.watch<ThemeProvider>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (auth.user?.profilePicture != null)
                    CircleAvatar(
                      backgroundImage:
                          NetworkImage(auth.user!.profilePicture!),
                      radius: 30,
                    )
                  else
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: colors.primaryContainer,
                      child: Text(
                        (auth.user?.name.isNotEmpty ?? false)
                            ? auth.user!.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colors.onPrimaryContainer),
                      ),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.user?.name ?? 'No Name',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          auth.user?.email ?? '',
                          style: TextStyle(
                              fontSize: 13,
                              color: colors.onSurface.withValues(alpha: 0.6)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Appearance section
          const _SectionHeader(label: 'Appearance'),
          Card(
            child: SwitchListTile(
              title:       const Text('Dark Mode'),
              subtitle:    Text(theme.isDark ? 'Enabled' : 'Disabled'),
              secondary:   Icon(
                theme.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: colors.primary,
              ),
              value:       theme.isDark,
              onChanged:   (_) => context.read<ThemeProvider>().toggleTheme(),
            ),
          ),
          const SizedBox(height: 20),

          // About section
          const _SectionHeader(label: 'About'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading:   Icon(Icons.info_outline_rounded, color: colors.primary),
                  title:     const Text('Version'),
                  trailing:  const Text('1.0.0',
                      style: TextStyle(color: Colors.grey)),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading:   Icon(Icons.code_rounded, color: colors.primary),
                  title:     const Text('Built with Flutter & Firebase'),
                  subtitle:  const Text('Node.js + MySQL backend'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sign out
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon:  const Icon(Icons.logout_rounded),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.error,
                side:            BorderSide(color: colors.error),
                padding:         const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title:   const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: colors.error,
                              foregroundColor: colors.onError),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Sign Out')),
                    ],
                  ),
                );
                if (ok == true && context.mounted) {
                  await context.read<AuthProvider>().signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize:      11,
          fontWeight:    FontWeight.w700,
          color:         colors.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
