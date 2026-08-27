import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/profile_refresh_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final settings = context.watch<SettingsProvider>();
    context.watch<ProfileRefreshProvider>();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          const Text('Profile',
              style: TextStyle(fontFamily: 'Playfair', fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.textSecondary, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.onboardingButton,
                  backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                  child: user?.photoURL == null
                      ? Text(
                    (user?.displayName?.isNotEmpty == true ? user!.displayName![0] : user?.email?[0] ?? '?').toUpperCase(),
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, color: AppColors.white),
                  )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _editDisplayName(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName?.isNotEmpty == true ? user!.displayName! : 'Reader',
                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(user?.email ?? '', style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const _SectionLabel('Preferences'),
          _SettingsSwitchTile(
            icon: Icons.notifications_none,
            label: 'Notifications',
            value: settings.notificationsEnabled,
            onChanged: (value) => context.read<SettingsProvider>().setNotificationsEnabled(value),
          ),
          const SizedBox(height: 20),
          const _SectionLabel('Support'),
          _SettingsTile(icon: Icons.help_outline, label: 'Help & FAQ', onTap: () => _showHelpDialog(context)),
          _SettingsTile(icon: Icons.info_outline, label: 'About Storyn', onTap: () => _showAboutDialog(context)),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
              label: const Text('Log out', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.redAccent)),
              onPressed: () => _confirmLogout(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('Help & FAQ', style: TextStyle(fontFamily: 'Poppins', fontSize: 16)),
        content: const Text(
          'Discover books by mood or genre on Home, or search directly on Explore. '
              'Tap "Add to library" on any book to save it — choose a reading status '
              '(Plan to read, Currently reading, Completed) and tag it into custom collections.\n\n'
              'In your Library, tap into any folder to see its books, long-press a custom '
              'collection to delete it, and tap the × on any book to remove it entirely.\n\n'
              'Import your own EPUB files from a saved book\'s card to read them right in the app, '
              'complete with bookmarks and progress tracking.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 13, height: 1.6),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Got it'))],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Storyn',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.auto_stories, color: AppColors.onboardingButton, size: 32),
      applicationLegalese: '© 2026 Storyn. All rights reserved.',
      children: const [
        SizedBox(height: 16),
        Text(
          'Storyn is your personal reading companion — discover books by mood or genre, '
              'organize your reading into custom collections, track progress from "plan to read" '
              'to "completed," and read your own EPUB files without leaving the app.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 13, height: 1.5),
        ),
        SizedBox(height: 12),
        Text(
          'Book data powered by Google Books and Open Library. Built with Flutter.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.dotActive),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('Log out?', style: TextStyle(fontFamily: 'Poppins', fontSize: 16)),
        content: const Text('You can log back in anytime.', style: TextStyle(fontFamily: 'Inter', fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/welcome');
            },
            child: const Text('Log out', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _editDisplayName(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final controller = TextEditingController(text: user?.displayName ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('Edit name', style: TextStyle(fontFamily: 'Poppins', fontSize: 16)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Your name'),
          style: const TextStyle(fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await FirebaseAuth.instance.currentUser?.updateDisplayName(newName);
                await FirebaseAuth.instance.currentUser?.reload();
                if (dialogContext.mounted) {
                  Provider.of<ProfileRefreshProvider>(dialogContext, listen: false).refresh();
                }
              }
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.dotActive)),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;
  const _SettingsTile({required this.icon, required this.label, this.trailing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textPrimary),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textPrimary))),
            if (trailing != null) Text(trailing!, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.dotActive)),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.dotInactive),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SettingsSwitchTile({required this.icon, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textPrimary),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textPrimary))),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.onboardingButton),
        ],
      ),
    );
  }
}