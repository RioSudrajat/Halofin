import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class BookingPaymentScreen extends StatelessWidget {
  final String consultantId;
  const BookingPaymentScreen({super.key, required this.consultantId});

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
            Text('Langkah 4 dari 4', style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xs),
            Text('Pembayaran', style: textTheme.displaySmall),
            const SizedBox(height: AppSpacing.xl),
            
            // Ringkasan Booking
            Text('Ringkasan Jadwal', style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppSpacing.cardRadius), border: Border.all(color: AppColors.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: AppColors.primaryDark),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Budi Santoso', style: textTheme.titleLarge),
                    ],
                  ),
                  const Divider(height: AppSpacing.lg),
                  _buildSummaryRow(context, 'Tanggal', '14 Mei 2024'),
                  const SizedBox(height: AppSpacing.sm),
                  _buildSummaryRow(context, 'Waktu', '10:00 - 11:00 WIB'),
                  const SizedBox(height: AppSpacing.sm),
                  _buildSummaryRow(context, 'Layanan', 'Video Call 60 Menit'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // Rincian Harga
            Text('Rincian Harga', style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            _buildSummaryRow(context, 'Biaya Konsultasi', 'Rp 250.000'),
            const SizedBox(height: AppSpacing.sm),
            _buildSummaryRow(context, 'Biaya Layanan', 'Rp 5.000'),
            const SizedBox(height: AppSpacing.sm),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Bayar', style: textTheme.titleLarge),
                Text('Rp 255.000', style: textTheme.titleLarge?.copyWith(color: AppColors.primaryDark)),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            ElevatedButton(
              onPressed: () {
                // Mock success
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pembayaran Berhasil! Jadwal Dikonfirmasi.')));
                context.go('/home');
              },
              child: const Text('Bayar Sekarang', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String key, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(key, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        Text(val, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
