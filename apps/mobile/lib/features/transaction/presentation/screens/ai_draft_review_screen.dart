import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class AiDraftReviewScreen extends StatelessWidget {
  const AiDraftReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Review Transaksi AI'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.edgeMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppSpacing.cardRadius), border: Border.all(color: AppColors.info)),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.info),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text('AI mendeteksi 1 transaksi dari struk. Silakan periksa kembali.', style: textTheme.bodySmall?.copyWith(color: AppColors.info))),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            TextFormField(
              initialValue: '55000',
              decoration: const InputDecoration(labelText: 'Jumlah', prefixText: 'Rp ', filled: true),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              initialValue: 'Makan Malam HokBen',
              decoration: const InputDecoration(labelText: 'Catatan', filled: true),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: 'Makan',
              decoration: const InputDecoration(labelText: 'Kategori', filled: true),
              items: ['Makan', 'Transportasi'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {},
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(), 
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                    child: const Text('Hapus'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.go('/transaction/history'),
                    child: const Text('Konfirmasi'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
