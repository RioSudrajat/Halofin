import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';

class ReportDashboardScreen extends StatelessWidget {
  const ReportDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Portfolio Keuangan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Januari 2026', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    const Icon(Icons.expand_more, size: 20),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.filter_list, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text('Filter', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Area Chart
            Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}jt', style: TextStyle(fontSize: 9, color: Colors.grey.shade400));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final labels = ['Sep', 'Oct', 'Nov', 'Dec', 'Jan', 'Feb'];
                          final idx = value.toInt();
                          if (idx >= 0 && idx < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(labels[idx], style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
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
                        FlSpot(0, 18), FlSpot(1, 19.5), FlSpot(2, 21), FlSpot(3, 20.5), FlSpot(4, 24.5), FlSpot(5, 26),
                      ],
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: index == 4 ? 5 : 0,
                            color: AppColors.primary,
                            strokeColor: Colors.white,
                            strokeWidth: 2,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.primary.withValues(alpha: 0.3), AppColors.primary.withValues(alpha: 0.0)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Balance Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Net Balance', 'Rp 24.500.000', badge: '+12%', badgeColor: Colors.green),
                  Divider(height: 24, color: Colors.grey.shade100),
                  _buildSummaryRow('Income bulan ini', 'Rp 8.500.000', icon: Icons.arrow_downward, iconColor: Colors.green.shade600),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Expense bulan ini', 'Rp 6.200.000', icon: Icons.arrow_upward, iconColor: Colors.red.shade600),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Expense Breakdown
            Text('Breakdown Pengeluaran', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  // Donut chart
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 28,
                        sections: [
                          PieChartSectionData(value: 35, color: Colors.orange, radius: 18, showTitle: false),
                          PieChartSectionData(value: 20, color: Colors.blue, radius: 18, showTitle: false),
                          PieChartSectionData(value: 18, color: Colors.purple, radius: 18, showTitle: false),
                          PieChartSectionData(value: 15, color: Colors.pink, radius: 18, showTitle: false),
                          PieChartSectionData(value: 12, color: Colors.grey.shade400, radius: 18, showTitle: false),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Legend
                  Expanded(
                    child: Column(
                      children: [
                        _buildBreakdownRow('Makan', '35%', 'Rp 2.170.000', Colors.orange),
                        _buildBreakdownRow('Transport', '20%', 'Rp 1.240.000', Colors.blue),
                        _buildBreakdownRow('Tagihan', '18%', 'Rp 1.116.000', Colors.purple),
                        _buildBreakdownRow('Hiburan', '15%', 'Rp 930.000', Colors.pink),
                        _buildBreakdownRow('Lainnya', '12%', 'Rp 744.000', Colors.grey.shade400),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recommendations
            Row(
              children: [
                const Icon(Icons.tips_and_updates, size: 20, color: AppColors.primaryDark),
                const SizedBox(width: 8),
                Text('Rekomendasi', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            _buildRecommendationCard(
              text: 'Pengeluaran makan kamu naik 15% dari bulan lalu. Coba set budget Rp 1.500.000 untuk bulan depan.',
              ctaText: 'Set Budget Makan',
              ctaColor: AppColors.primary,
              onTap: () => context.go('/budget'),
            ),
            const SizedBox(height: 12),
            _buildRecommendationCard(
              text: 'Tabungan kamu sudah naik Rp 2.300.000 dalam 3 bulan. Pertimbangkan investasi reksa dana pasar uang.',
              ctaText: 'Lihat Konsultan Investasi',
              ctaColor: Colors.blue,
              onTap: () => context.go('/consult'),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {String? badge, Color? badgeColor, IconData? icon, Color? iconColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 8),
            ],
            Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ],
        ),
        Row(
          children: [
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor?.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(badge, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor)),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildBreakdownRow(String label, String pct, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
          Text(pct, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
          const SizedBox(width: 8),
          Text(amount, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard({required String text, required String ctaText, required Color ctaColor, VoidCallback? onTap}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ctaColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ctaColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: ctaColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(ctaText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}
