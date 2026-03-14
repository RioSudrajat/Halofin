import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xl),
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.person, size: 50, color: AppColors.primaryDark),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Ahmad Supriyadi', style: Theme.of(context).textTheme.displaySmall),
            Text('ahmad@example.com', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xl),
            
            _buildSection(context, 'Akun', Icons.person_outline),
            _buildSection(context, 'Keamanan & Privasi', Icons.lock_outline),
            _buildSection(context, 'Notifikasi', Icons.notifications_none),
            _buildSection(context, 'Bantuan & Dukungan', Icons.help_outline),
            
            const SizedBox(height: AppSpacing.xxl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
              child: OutlinedButton(
                onPressed: () {}, // Trigger logout
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Keluar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.primaryDark),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleLarge),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: () {},
    );
  }
}
