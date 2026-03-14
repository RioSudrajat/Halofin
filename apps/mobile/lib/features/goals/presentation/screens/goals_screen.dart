import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/finance_tabs.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

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
              selectedIndex: 0, // 0 = Goals, 1 = Budget, 2 = Bills
              onTabChanged: (index) {
                if (index == 1) context.go('/budget');
                if (index == 2) context.go('/bills');
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Your Saving Goals', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.add, color: AppColors.primaryDark, size: 18),
                    label: Text('New Goal', style: textTheme.labelMedium?.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Goals Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.72,
                children: [
                  _buildGoalCard(
                    context,
                    name: 'MacBook Pro',
                    timeLeft: '14 months left',
                    tagColor: Colors.grey.shade100,
                    tagTextColor: Colors.grey.shade600,
                    icon: Icons.laptop_mac,
                    progress: 0.75,
                    target: 'Rp 24.000.000',
                    shortfall: 'Rp 6.000.000',
                    saved: 'Rp 18.000.000',
                  ),
                  _buildGoalCard(
                    context,
                    name: 'Emergency Fund',
                    timeLeft: 'Urgent',
                    tagColor: Colors.red.shade50,
                    tagTextColor: Colors.red.shade600,
                    icon: Icons.health_and_safety,
                    progress: 0.45,
                    target: 'Rp 50.000.000',
                    shortfall: 'Rp 27.500.000',
                    saved: 'Rp 22.500.000',
                  ),
                  _buildGoalCard(
                    context,
                    name: 'Japan Trip',
                    timeLeft: '8 months left',
                    tagColor: Colors.grey.shade100,
                    tagTextColor: Colors.grey.shade600,
                    icon: Icons.flight,
                    progress: 0.20,
                    target: 'Rp 35.000.000',
                    shortfall: 'Rp 28.000.000',
                    saved: 'Rp 7.000.000',
                  ),
                  _buildGoalCard(
                    context,
                    name: 'Tesla Model 3',
                    timeLeft: '3 years left',
                    tagColor: Colors.grey.shade100,
                    tagTextColor: Colors.grey.shade600,
                    icon: Icons.directions_car,
                    progress: 0.10,
                    target: 'Rp 800.000.000',
                    shortfall: 'Rp 720.000.000',
                    saved: 'Rp 80.000.000',
                  ),
                  
                  // Create New Goal Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid), // dashed ideally, but solid is fine for simple compat
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 56,
                          width: 56,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                          ),
                          child: const Icon(Icons.add, color: Colors.grey, size: 28),
                        ),
                        const SizedBox(height: 12),
                        const Text('Create New Goal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Smart Tip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.tips_and_updates, color: Colors.black, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Smart Tip', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.5),
                              children: [
                                const TextSpan(text: 'Based on your spending, you can save an extra '),
                                const TextSpan(text: 'Rp 500.000', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                                const TextSpan(text: ' this month by cutting down on coffee expenses.'),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildGoalCard(
    BuildContext context, {
    required String name,
    required String timeLeft,
    required Color tagColor,
    required Color tagTextColor,
    required IconData icon,
    required double progress,
    required String target,
    required String shortfall,
    required String saved,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const SizedBox(height: 16), // Space for top absolute items
                SizedBox(
                  height: 80,
                  width: 80,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 6,
                        backgroundColor: Colors.grey.shade100,
                        color: AppColors.primary,
                        strokeCap: StrokeCap.round,
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 24, color: Colors.grey.shade800),
                            const SizedBox(height: 2),
                            Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('Target: $target', style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
                Text('Kurang $shortfall', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.red)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Saved', style: TextStyle(fontSize: 9, color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
                      Text(saved, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(12)),
              child: Text(timeLeft, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: tagTextColor)),
            ),
          ),
          const Positioned(
            top: 12,
            right: 12,
            child: Icon(Icons.more_horiz, size: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
