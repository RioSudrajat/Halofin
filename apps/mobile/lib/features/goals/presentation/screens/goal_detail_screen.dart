import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/mock_providers.dart';
import '../../../budget/presentation/providers/finance_providers.dart';

class GoalDetailScreen extends ConsumerWidget {
  final String goalId;
  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);
    final wallets = ref.watch(walletsProvider);
    final goal = goals.firstWhere((g) => g.id == goalId, orElse: () => goals.first);
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final progress = goal.targetAmount > 0 ? (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0) : 0.0;
    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;
    final isComplete = progress >= 1.0;

    // Build contribution entries with wallet info
    final contributions = goal.contributions.entries.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            pinned: true,
            expandedHeight: 0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, size: 20),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                  child: const Icon(Icons.edit_outlined, size: 20),
                ),
                onPressed: () => context.push('/goal/edit/$goalId'),
              ),
            ],
            title: Text(goal.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
            centerTitle: true,
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Main progress card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isComplete
                          ? [Colors.green.shade50, Colors.green.shade100]
                          : [AppColors.primaryLight.withValues(alpha: 0.4), AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Column(
                    children: [
                      // Icon + progress ring
                      SizedBox(
                        height: 120, width: 120,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 8,
                              backgroundColor: Colors.white.withValues(alpha: 0.5),
                              color: isComplete ? Colors.green : AppColors.primaryDark,
                              strokeCap: StrokeCap.round,
                            ),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(goal.icon, size: 32, color: Colors.black87),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(progress * 100).toInt()}%',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Saved / Target
                      Text('Terkumpul', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                      const SizedBox(height: 4),
                      Text(
                        formatCurrency.format(goal.savedAmount),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'dari ${formatCurrency.format(goal.targetAmount)}',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
                      ),

                      const SizedBox(height: 16),

                      // Info chips
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildInfoChip(
                            icon: Icons.calendar_today,
                            label: '$daysLeft hari lagi',
                            color: daysLeft < 30 ? Colors.red : Colors.grey.shade700,
                          ),
                          const SizedBox(width: 12),
                          _buildInfoChip(
                            icon: Icons.flag,
                            label: goal.priority,
                            color: goal.priority == 'Urgent' ? Colors.red : (goal.priority == 'Wants' ? Colors.blue : Colors.orange),
                          ),
                          if (isComplete) ...[
                            const SizedBox(width: 12),
                            _buildInfoChip(icon: Icons.check_circle, label: 'Selesai!', color: Colors.green),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Source Funds section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Text('Sumber Dana', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _addNewSource(context, goalId),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, size: 16, color: Colors.white),
                              SizedBox(width: 4),
                              Text('Tambah', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Source list
                if (contributions.isEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 56, width: 56,
                          decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                          child: Icon(Icons.account_balance_wallet_outlined, size: 28, color: Colors.grey.shade400),
                        ),
                        const SizedBox(height: 12),
                        Text('Belum ada sumber dana', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
                        const SizedBox(height: 4),
                        Text(
                          'Tekan + untuk menambahkan dana\nmelalui transaksi transfer',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  )
                else
                  ...contributions.map((entry) {
                    final walletId = entry.key;
                    final amount = entry.value;
                    final wallet = wallets.where((w) => w.id == walletId).isNotEmpty
                        ? wallets.firstWhere((w) => w.id == walletId)
                        : null;
                    final walletName = wallet?.name ?? 'Wallet Dihapus';
                    final walletType = wallet?.type ?? '';

                    return GestureDetector(
                      onTap: () => _showSourceOptions(context, ref, goalId, walletId, walletName, amount),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(_getWalletIcon(walletType), size: 22, color: AppColors.primaryDark),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(walletName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                  const SizedBox(height: 2),
                                  Text(walletType, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(formatCurrency.format(amount), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text(
                                  goal.savedAmount > 0 ? '${((amount / goal.savedAmount) * 100).toInt()}%' : '0%',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade400),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
                          ],
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addNewSource(BuildContext context, String goalId) {
    context.push('/transaction/entry', extra: {
      'type': 'Transfer',
      'targetGoalId': goalId,
    });
  }

  void _showSourceOptions(BuildContext context, WidgetRef ref, String goalId, String walletId, String walletName, double currentAmount) {
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Text(walletName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Kontribusi: ${formatCurrency.format(currentAmount)}', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
              const SizedBox(height: 24),

              // Tambah
              _buildOptionTile(
                icon: Icons.add_circle_outline,
                label: 'Tambah Dana',
                subtitle: 'Transfer dari wallet ini ke goal',
                color: Colors.green,
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/transaction/entry', extra: {
                    'type': 'Transfer',
                    'targetGoalId': goalId,
                    'sourceWalletId': walletId,
                  });
                },
              ),
              const SizedBox(height: 8),

              // Kurangi
              _buildOptionTile(
                icon: Icons.remove_circle_outline,
                label: 'Tarik Dana',
                subtitle: 'Kembalikan dana ke wallet asal',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/transaction/entry', extra: {
                    'type': 'Transfer',
                    'sourceWalletId': 'goal:$goalId:$walletId',
                    'targetWalletId': walletId,
                  });
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: color)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  IconData _getWalletIcon(String type) {
    switch (type) {
      case 'Bank': return Icons.account_balance;
      case 'E-Wallet': return Icons.account_balance_wallet;
      case 'Cash': return Icons.attach_money;
      case 'Stock': return Icons.candlestick_chart;
      case 'Crypto': return Icons.currency_bitcoin;
      case 'Mutual Fund': return Icons.pie_chart;
      case 'Bond': return Icons.receipt_long;
      case 'Deposit': return Icons.savings;
      default: return Icons.account_balance_wallet;
    }
  }
}
