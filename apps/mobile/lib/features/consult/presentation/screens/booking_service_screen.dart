import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class BookingServiceScreen extends StatefulWidget {
  final String consultantId;
  const BookingServiceScreen({super.key, required this.consultantId});

  @override
  State<BookingServiceScreen> createState() => _BookingServiceScreenState();
}

class _BookingServiceScreenState extends State<BookingServiceScreen> {
  int _selectedTier = 1; // 0, 1

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Jadwal'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.edgeMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Langkah 1 dari 4', style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xs),
            Text('Pilih Layanan', style: textTheme.displaySmall),
            const SizedBox(height: AppSpacing.lg),
            
            // Consultant Preview Mini
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(backgroundColor: AppColors.background, child: Icon(Icons.person)),
              title: Text('Budi Santoso', style: textTheme.titleLarge),
              subtitle: Text('Spesialis Investasi', style: textTheme.bodySmall),
            ),
            const Divider(height: AppSpacing.xxl),
            
            // Tiers
            _buildTierCard(context, 0, 'Konsultasi 30 Menit (Chat)', 'Cocok untuk pertanyaan singkat', 'Rp 150.000'),
            const SizedBox(height: AppSpacing.md),
            _buildTierCard(context, 1, 'Konsultasi 60 Menit (Video)', 'Bedah portofolio menyeluruh dengan video call', 'Rp 250.000'),
            
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton(
              onPressed: () => context.push('/booking/${widget.consultantId}/time'),
              child: const Text('Lanjut Pilih Jadwal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierCard(BuildContext context, int index, String title, String desc, String price) {
    final isSelected = _selectedTier == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTier = index),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: isSelected ? AppColors.primaryDark : AppColors.border, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primaryDark : AppColors.border,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text(desc, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(price, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
