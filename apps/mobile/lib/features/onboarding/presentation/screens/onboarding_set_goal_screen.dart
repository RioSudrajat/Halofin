import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class OnboardingSetGoalScreen extends StatelessWidget {
  const OnboardingSetGoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Langkah 2 dari 2'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.go('/home'),
            child: const Text('Lewati'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin, vertical: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Apa goal utamamu?', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: AppSpacing.xs),
            Text('Pilih satu untuk referensi AI', 
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            _buildGoalCard(context, 'Dana Darurat 6 Bulan', 'Disarankan untuk keamanan', Icons.shield_outlined, true),
            const SizedBox(height: AppSpacing.md),
            _buildGoalCard(context, 'Liburan Akhir Tahun', 'Mulai menabung untuk liburan', Icons.flight_takeoff, false),
            const SizedBox(height: AppSpacing.md),
            _buildGoalCard(context, 'Beli Gadget Baru', 'Upgrade alat tempur', Icons.devices, false),
            const SizedBox(height: AppSpacing.md),
            _buildGoalCard(context, 'Custom Goal', 'Setel tujuan spesifikmu', Icons.add_circle_outline, false),
            
            const SizedBox(height: AppSpacing.xxl),
            
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Simpan & Mulai', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, String title, String subtitle, IconData icon, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: isSelected ? AppColors.primaryDark : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : AppColors.background,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isSelected ? AppColors.primaryDark : AppColors.textPrimary),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        trailing: isSelected 
          ? const Icon(Icons.check_circle, color: AppColors.primaryDark)
          : null,
      ),
    );
  }
}
