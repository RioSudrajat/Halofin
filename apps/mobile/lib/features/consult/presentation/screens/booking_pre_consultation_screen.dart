import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class BookingPreConsultationScreen extends StatefulWidget {
  final String consultantId;
  const BookingPreConsultationScreen({super.key, required this.consultantId});

  @override
  State<BookingPreConsultationScreen> createState() => _BookingPreConsultationScreenState();
}

class _BookingPreConsultationScreenState extends State<BookingPreConsultationScreen> {
  bool _agreed = false;

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
            Text('Langkah 3 dari 4', style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xs),
            Text('Persiapan Konsultasi', style: textTheme.displaySmall),
            const SizedBox(height: AppSpacing.xl),
            
            Text('Topik Utama Konsultasi', style: textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(filled: true, fillColor: AppColors.surface, border: OutlineInputBorder()),
              items: ['Review Portofolio', 'Perencanaan Pensiun', 'Manajemen Utang']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {},
              hint: const Text('Pilih Topik Terkait'),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            Text('Ceritakan Kondisi Keuangan Saat Ini', style: textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Misal: Saya punya utang Rp 50jt dicicil 2 tahun, dan ingin investasi...',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Upload Document Placeholder
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border, style: BorderStyle.none),
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                color: AppColors.background,
              ),
              child: Column(
                children: [
                  const Icon(Icons.upload_file, size: 40, color: AppColors.primaryDark),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Upload Dokumen Pendukung (Opsional)', style: textTheme.bodyMedium),
                  Text('Format PDF, JPG, PNG', style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton(onPressed: () {}, child: const Text('Pilih File')),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(value: _agreed, onChanged: (v) => setState(() => _agreed = v!)),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text('Saya memastikan informasi yang diberikan benar.', style: textTheme.bodyMedium),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton(
              onPressed: _agreed ? () => context.push('/booking/${widget.consultantId}/payment') : null,
              child: const Text('Lanjut Pembayaran'),
            ),
          ],
        ),
      ),
    );
  }
}
