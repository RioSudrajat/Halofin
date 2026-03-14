import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';

class WalletDetailScreen extends StatelessWidget {
  final String walletId;
  const WalletDetailScreen({super.key, required this.walletId});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Mock data based on walletId
    final walletData = _getWalletData(walletId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Detail Wallet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
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
                          Text(walletData['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                          if (walletData['isAutoSync'] == true)
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
                  Text(walletData['balance'] as String, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
                  if (walletData['isAutoSync'] == true) ...[
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

            // Recent Mutations
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
            _buildMutationItem(icon: Icons.fastfood, iconColor: Colors.orange, iconBg: Colors.orange.shade50, title: "McDonald's", subtitle: 'Hari ini, 19:30', amount: '-Rp 125.000', isExpense: true),
            _buildMutationItem(icon: Icons.work, iconColor: Colors.blue, iconBg: Colors.blue.shade50, title: 'Gaji PT ABC', subtitle: '25 Feb 2026', amount: '+Rp 10.000.000', isExpense: false),
            _buildMutationItem(icon: Icons.shopping_bag, iconColor: Colors.pink, iconBg: Colors.pink.shade50, title: 'Tokopedia', subtitle: '24 Feb 2026', amount: '-Rp 350.000', isExpense: true),
            _buildMutationItem(icon: Icons.directions_car, iconColor: Colors.green, iconBg: Colors.green.shade50, title: 'Grab Car', subtitle: '23 Feb 2026', amount: '-Rp 45.000', isExpense: true),
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

  Map<String, dynamic> _getWalletData(String id) {
    switch (id) {
      case 'bca':
        return {'name': 'BCA', 'balance': 'Rp 150.000.000', 'isAutoSync': true};
      case 'bni':
        return {'name': 'BNI', 'balance': 'Rp 5.000.000', 'isAutoSync': true};
      case 'cash':
        return {'name': 'Cash', 'balance': 'Rp 500.000', 'isAutoSync': false};
      default:
        return {'name': 'Wallet', 'balance': 'Rp 0', 'isAutoSync': false};
    }
  }
}
