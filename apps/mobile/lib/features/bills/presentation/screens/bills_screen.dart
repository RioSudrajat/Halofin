import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/finance_tabs.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('January 2026', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(width: 4),
            Icon(Icons.expand_more, size: 20, color: Colors.black87),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.sm),
            FinanceTabs(
              selectedIndex: 2, // 0 = Goals, 1 = Budget, 2 = Bills
              onTabChanged: (index) {
                if (index == 0) context.go('/goals');
                if (index == 1) context.go('/budget');
              },
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Total Bills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOTAL BILLS FOR JAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Text('Rp', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            Text('1.286.000', style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -0.5)),
                          ],
                        ),
                        const Text('65%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.65,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Paid: Rp 835.900', style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                        const Text('Remaining: Rp 450.100', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // Upcoming Payments
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Upcoming Payments', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
              child: Column(
                children: [
                  _buildPaymentCard(
                    title: 'Netflix Premium',
                    dateTag: 'Due in 2 days',
                    dateTagColor: Colors.red.shade50,
                    dateTagTextColor: Colors.red.shade600,
                    dateStr: 'Jan 28',
                    amount: 'Rp 186.000',
                    actionLabel: 'Pay Now',
                    actionColor: AppColors.primaryDark,
                    icon: Icons.movie,
                    iconBgColor: Colors.black,
                    iconColor: Colors.red.shade600,
                  ),
                  _buildPaymentCard(
                    title: 'Spotify Family',
                    dateTag: 'Due in 5 days',
                    dateTagColor: Colors.orange.shade50,
                    dateTagTextColor: Colors.orange.shade600,
                    dateStr: 'Jan 31',
                    amount: 'Rp 86.000',
                    actionLabel: 'Pay Now',
                    actionColor: AppColors.primaryDark,
                    icon: Icons.graphic_eq,
                    iconBgColor: Colors.green.shade500,
                    iconColor: Colors.white,
                  ),
                  _buildPaymentCard(
                    title: 'IndiHome Fiber',
                    dateTag: 'Feb 05',
                    dateTagColor: Colors.grey.shade100,
                    dateTagTextColor: Colors.grey.shade500,
                    dateStr: null,
                    amount: 'Rp 350.000',
                    actionLabel: 'Auto-pay on',
                    actionColor: Colors.grey.shade400,
                    icon: Icons.router,
                    iconBgColor: Colors.blue.shade600,
                    iconColor: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Paid this month
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Paid this month', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
              child: Opacity(
                opacity: 0.6,
                child: Column(
                  children: [
                    _buildPaidCard(
                      title: 'Water Bill (PDAM)',
                      dateStr: 'Paid on Jan 15',
                      amount: 'Rp 125.000',
                      icon: Icons.water_drop,
                    ),
                    _buildPaidCard(
                      title: 'Electricity (PLN)',
                      dateStr: 'Paid on Jan 10',
                      amount: 'Rp 539.000',
                      icon: Icons.bolt,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl * 2),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard({
    required String title,
    required String dateTag,
    required Color dateTagColor,
    required Color dateTagTextColor,
    String? dateStr,
    required String amount,
    required String actionLabel,
    required Color actionColor,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: dateTagColor, borderRadius: BorderRadius.circular(4)),
                      child: Text(dateTag, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: dateTagTextColor)),
                    ),
                    if (dateStr != null) ...[
                      const SizedBox(width: 6),
                      Text(dateStr, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                    ]
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              Text(actionLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: actionColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaidCard({
    required String title,
    required String dateStr,
    required String amount,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Icon(icon, color: Colors.grey.shade400, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey.shade700)),
                const SizedBox(height: 2),
                Text(dateStr, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
              ],
            ),
          ),
          Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
