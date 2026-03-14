import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/filter_chip_widget.dart';
import '../../../../shared/widgets/interactive_donut_chart.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String _activeFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Wallet Finansialmu', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Donut Chart Container
            Container(
              margin: const EdgeInsets.all(AppSpacing.edgeMargin),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: InteractiveDonutChart(
                centerTitle: 'Total Balance',
                centerAmount: 'Rp 215.500.000',
                data: [
                  ChartData('E-Wallet', 35, AppColors.primary),
                  ChartData('Bank', 30, const Color(0xFF1F2937)),
                  ChartData('Investasi', 20, const Color(0xFF9CA3AF)),
                  ChartData('Lainnya', 15, const Color(0xFF065F46)),
                ],
              ),
            ),
            
            // Your Wallets Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text('Your Wallets', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                   Text('Sort by Value', style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
              child: Row(
                children: ['Semua', 'E-Wallet', 'Bank', 'Investasi', 'Lainnya'].map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: FilterChipWidget(
                      label: filter,
                      isSelected: _activeFilter == filter,
                      onTap: () => setState(() => _activeFilter = filter),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Wallet Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.1,
                children: [
                  // Add New
                  GestureDetector(
                    onTap: () => context.push('/wallet/add'),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid, width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: Colors.black, size: 28),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text('Add New', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text('Wallet or Asset', style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                  
                  // Wallet Card 1
                  _buildWalletCard(
                    context,
                    name: 'Bank BCA',
                    type: 'Akun Otomatis',
                    balance: 'Rp 85.450.000',
                    iconColor: Colors.blue.shade50,
                    iconText: 'BCA',
                    progressColor: Colors.blue.shade600,
                    progressValue: 0.8,
                  ),
                  _buildWalletCard(
                    context,
                    name: 'Bank BNI',
                    type: 'Akun Otomatis',
                    balance: 'Rp 2.500.000',
                    iconColor: const Color(0xFF005EAA),
                    iconText: 'BNI',
                    progressColor: const Color(0xFF005EAA),
                    progressValue: 0.15,
                    isIconTextWhite: true,
                  ),
                  _buildWalletCard(
                    context,
                    name: 'Dana',
                    type: 'Akun Otomatis',
                    balance: 'Rp 850.000',
                    iconColor: const Color(0xFF118EEA),
                    iconText: 'DANA',
                    progressColor: const Color(0xFF118EEA),
                    progressValue: 0.08,
                    isIconTextWhite: true,
                    iconTextSize: 10,
                  ),
                  _buildWalletCard(
                    context,
                    name: 'GoPay',
                    type: 'Akun Otomatis',
                    balance: 'Rp 53.800.000',
                    iconColor: const Color(0xFF00AED6),
                    iconText: 'gopay',
                    progressColor: const Color(0xFF00AED6),
                    progressValue: 0.6,
                    isIconTextWhite: true,
                    iconTextSize: 10,
                  ),
                  _buildWalletCard(
                    context,
                    name: 'IndoPremier',
                    type: 'Akun Manual',
                    balance: 'Rp 32.300.000',
                    iconColor: Colors.yellow.shade50,
                    iconText: 'IPOV',
                    progressColor: Colors.yellow.shade600,
                    progressValue: 0.45,
                  ),
                  _buildWalletCard(
                    context,
                    name: 'Binance',
                    type: 'Akun Manual',
                    balance: 'Rp 29.150.000',
                    iconColor: Colors.orange.shade50,
                    iconText: 'BNC',
                    progressColor: Colors.orange.shade400,
                    progressValue: 0.4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl * 2),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(
    BuildContext context, {
    required String name,
    required String type,
    required String balance,
    required Color iconColor,
    required String iconText,
    required Color progressColor,
    required double progressValue,
    bool isIconTextWhite = false,
    double iconTextSize = 12,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => context.push('/wallet/detail'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: iconColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    iconText,
                    style: TextStyle(
                      color: isIconTextWhite ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: iconTextSize,
                    ),
                  ),
                ),
                const Icon(Icons.more_horiz, color: Colors.grey, size: 20),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: textTheme.labelMedium?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                Text(type, style: textTheme.labelSmall?.copyWith(color: Colors.grey.shade400, fontSize: 9)),
                const SizedBox(height: 2),
                Text(balance, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  height: 4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progressValue,
                    child: Container(
                      decoration: BoxDecoration(
                        color: progressColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
