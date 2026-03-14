import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class OnboardingWalletSetupScreen extends StatefulWidget {
  const OnboardingWalletSetupScreen({super.key});

  @override
  State<OnboardingWalletSetupScreen> createState() => _OnboardingWalletSetupScreenState();
}

class _OnboardingWalletSetupScreenState extends State<OnboardingWalletSetupScreen> {
  String _selectedType = 'E-Wallet';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Langkah 1 dari 2'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.edgeMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Setup Dompet Utama', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: AppSpacing.xs),
            Text('Dari mana sumber dana utamamu berasal?', 
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            Text('Pilih Jenis', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: ['E-Wallet', 'Bank', 'Cash', 'Credit'].map((type) {
                final isSelected = _selectedType == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedType = type);
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nama Dompet (cth: GoPay Utama)'),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            TextFormField(
              decoration: const InputDecoration(labelText: 'Saldo Awal', prefixText: 'Rp '),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            ElevatedButton(
              onPressed: () => context.go('/onboarding/goal'),
              child: const Text('Lanjut ke Goals', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
