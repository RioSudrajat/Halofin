import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class BookingTimeScreen extends StatefulWidget {
  final String consultantId;
  const BookingTimeScreen({super.key, required this.consultantId});

  @override
  State<BookingTimeScreen> createState() => _BookingTimeScreenState();
}

class _BookingTimeScreenState extends State<BookingTimeScreen> {
  int _selectedDateIndex = 0;
  int _selectedTimeIndex = 1;

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
            Text('Langkah 2 dari 4', style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xs),
            Text('Pilih Waktu', style: textTheme.displaySmall),
            const SizedBox(height: AppSpacing.xl),
            
            Text('Pilih Tanggal', style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  final isSelected = _selectedDateIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDateIndex = index),
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.only(right: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Sen', style: textTheme.bodySmall?.copyWith(
                            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                          )),
                          Text('${12 + index}', style: textTheme.titleLarge?.copyWith(
                            color: isSelected ? AppColors.textPrimary : AppColors.textPrimary,
                          )),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            Text('Pilih Jam', style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: List.generate(6, (index) {
                final isSelected = _selectedTimeIndex == index;
                final times = ['09:00', '10:00', '11:00', '13:00', '14:00', '15:00'];
                return ChoiceChip(
                  label: Text(times[index]),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedTimeIndex = index);
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                );
              }),
            ),
            
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton(
              onPressed: () => context.push('/booking/${widget.consultantId}/pre-consult'),
              child: const Text('Lanjut Isi Detail'),
            ),
          ],
        ),
      ),
    );
  }
}
