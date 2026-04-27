import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/mock_providers.dart';
import '../../../../core/models/transaction_model.dart';

class WalletDetailScreen extends ConsumerWidget {
  final String walletId;
  const WalletDetailScreen({super.key, required this.walletId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final wallets = ref.watch(walletsProvider);
    
    // Find wallet by id, or fallback to first if not found (or return error)
    final wallet = wallets.firstWhere(
      (w) => w.id == walletId, 
      orElse: () => wallets.isNotEmpty ? wallets.first : wallets.first // Temporary fallback
    );

    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Detail Wallet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Hapus Wallet?'),
                  content: Text('Yakin mau hapus ${wallet.name}? Aksi ini tidak bisa dibatalkan.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                    TextButton(
                      onPressed: () {
                        ref.read(walletsProvider.notifier).deleteWallet(wallet.id);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wallet berhasil dihapus')));
                        context.pop();
                      },
                      child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.settings, size: 18),
            label: const Text('Edit', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF334155)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF1E293B).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.account_balance, size: 22, color: Colors.black),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(wallet.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                          if (wallet.isAutoSync)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(4)),
                              child: const Text('⚡ Auto-Sync', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Saldo Saat Ini', style: TextStyle(fontSize: 12, color: Colors.white60)),
                  const SizedBox(height: 4),
                  Text(formatCurrency.format(wallet.balance), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
                  
                  if (wallet.returnPercentage != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(wallet.returnPercentage! >= 0 ? Icons.trending_up : Icons.trending_down, size: 14, color: wallet.returnPercentage! >= 0 ? Colors.greenAccent : Colors.redAccent),
                        const SizedBox(width: 6),
                        Text('Return: ${wallet.returnPercentage!.toStringAsFixed(2)}%', style: TextStyle(fontSize: 12, color: wallet.returnPercentage! >= 0 ? Colors.greenAccent : Colors.redAccent)),
                      ],
                    ),
                  ],

                  if (wallet.dividendDropDate != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text('Dividen: ${wallet.dividendDropDate!.day}/${wallet.dividendDropDate!.month}/${wallet.dividendDropDate!.year}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ],

                  if (wallet.isAutoSync) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.sync, size: 14, color: Colors.greenAccent.shade200),
                        const SizedBox(width: 6),
                        Text('Terakhir sync: Hari ini, 08:00', style: TextStyle(fontSize: 11, color: Colors.greenAccent.shade200)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.sync, size: 16, color: Colors.white),
                        label: const Text('Sinkronisasi Sekarang', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Trend Chart
            Text('Trend Saldo (Bulan Ini)', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 180,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final labels = ['1', '5', '10', '15', '20', '25', '30'];
                          final idx = value.toInt();
                          if (idx >= 0 && idx < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(labels[idx], style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 28,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 15), FlSpot(1, 14.5), FlSpot(2, 13.8), FlSpot(3, 14.2),
                        FlSpot(4, 12.5), FlSpot(5, 15.4), FlSpot(6, 15.4),
                      ],
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Recent Mutations — dynamic from transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mutasi Terakhir', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => context.push('/transaction/history'),
                  child: const Text('Lihat Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final allTx = ref.watch(transactionsProvider);
                final walletTx = allTx.where((tx) => tx.walletId == walletId || tx.targetWalletId == walletId).take(5).toList();
                if (walletTx.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text('Belum ada mutasi', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w600)),
                    ),
                  );
                }
                return Column(
                  children: walletTx.map((tx) {
                    final isExpense = tx.type == 'expense' || (tx.type == 'transfer' && tx.walletId == walletId);
                    final color = isExpense ? Colors.red : Colors.green;
                    return _buildMutationItem(
                      icon: tx.type == 'transfer' ? Icons.swap_horiz : (isExpense ? Icons.arrow_upward : Icons.arrow_downward),
                      iconColor: color,
                      iconBg: color.withValues(alpha: 0.1),
                      title: tx.title,
                      subtitle: '${tx.date.day}/${tx.date.month}/${tx.date.year}',
                      amount: '${isExpense ? "-" : "+"}${formatCurrency.format(tx.amount)}',
                      isExpense: isExpense,
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMutationItem({required IconData icon, required Color iconColor, required Color iconBg, required String title, required String subtitle, required String amount, required bool isExpense}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isExpense ? Colors.red.shade600 : Colors.green.shade600)),
        ],
      ),
    );
  }
}
