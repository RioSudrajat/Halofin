import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/filter_chip_widget.dart';
import '../../../../shared/widgets/interactive_donut_chart.dart';
import '../../../../core/providers/mock_providers.dart';
import '../../../../core/models/wallet_model.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  String _activeFilter = 'Semua';

  final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  Color _getIconColor(String type) {
    switch (type) {
      case 'Bank': return const Color(0xFF005EAA);
      case 'E-Wallet': return const Color(0xFF00AED6);
      case 'Mutual Fund': return Colors.teal;
      case 'Stock': return Colors.indigo;
      case 'Crypto': return Colors.orange;
      case 'Cash': return Colors.green;
      default: return Colors.grey;
    }
  }

  String _mapTypeToFilter(String type) {
    if (type == 'Bank') return 'Bank';
    if (type == 'E-Wallet') return 'E-Wallet';
    if (['Mutual Fund', 'Stock', 'Bond', 'Deposit', 'Crypto'].contains(type)) return 'Investasi';
    return 'Lainnya';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final wallets = ref.watch(walletsProvider);

    // Compute chart data
    double totalBank = 0, totalEwallet = 0, totalInvest = 0, totalOther = 0;
    double totalBalance = 0;
    for (var w in wallets) {
      totalBalance += w.balance;
      final f = _mapTypeToFilter(w.type);
      if (f == 'Bank') totalBank += w.balance;
      else if (f == 'E-Wallet') totalEwallet += w.balance;
      else if (f == 'Investasi') totalInvest += w.balance;
      else totalOther += w.balance;
    }

    final filteredWallets = wallets.where((w) {
      if (_activeFilter == 'Semua') return true;
      return _mapTypeToFilter(w.type) == _activeFilter;
    }).toList();

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
                  BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: InteractiveDonutChart(
                centerTitle: 'Total Balance',
                centerAmount: formatCurrency.format(totalBalance),
                data: [
                  if (totalEwallet > 0) ChartData('E-Wallet', (totalEwallet/totalBalance)*100, AppColors.primary),
                  if (totalBank > 0) ChartData('Bank', (totalBank/totalBalance)*100, const Color(0xFF1F2937)),
                  if (totalInvest > 0) ChartData('Investasi', (totalInvest/totalBalance)*100, const Color(0xFF9CA3AF)),
                  if (totalOther > 0) ChartData('Lainnya', (totalOther/totalBalance)*100, const Color(0xFF065F46)),
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
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.1,
                ),
                itemCount: filteredWallets.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Add New
                    return GestureDetector(
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
                    );
                  }

                  final wallet = filteredWallets[index - 1];
                  return _buildWalletCard(
                    context,
                    wallet: wallet,
                    totalBalance: totalBalance,
                  );
                },
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
    required WalletModel wallet,
    required double totalBalance,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final color = _getIconColor(wallet.type);
    final progressValue = totalBalance == 0 ? 0.0 : wallet.balance / totalBalance;

    return GestureDetector(
      onTap: () => context.push('/wallet/${wallet.id}'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
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
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(
                    wallet.name.substring(0, min(3, wallet.name.length)).toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const Icon(Icons.more_horiz, color: Colors.grey, size: 20),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(wallet.name, style: textTheme.labelMedium?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(wallet.isAutoSync ? 'Akun Otomatis' : 'Akun Manual', style: textTheme.labelSmall?.copyWith(color: Colors.grey.shade400, fontSize: 9)),
                const SizedBox(height: 2),
                Text(
                  formatCurrency.format(wallet.balance), 
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 4,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(2)),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progressValue.clamp(0.0, 1.0),
                    child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
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
