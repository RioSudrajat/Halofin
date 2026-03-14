import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/finance_tabs.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  int _selectedTab = 1; // 0 = Goals, 1 = Budget, 2 = Bills

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
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          FinanceTabs(
            selectedIndex: _selectedTab,
            onTabChanged: (index) => setState(() => _selectedTab = index),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: _buildContent(textTheme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(TextTheme textTheme) {
    switch (_selectedTab) {
      case 0:
        return _GoalsContent(key: const ValueKey('goals'), textTheme: textTheme);
      case 2:
        return _BillsContent(key: const ValueKey('bills'), textTheme: textTheme);
      default:
        return _BudgetContent(key: const ValueKey('budget'), textTheme: textTheme);
    }
  }
}

// ─────────────────────────────────────────────────────────
// BUDGET CONTENT
// ─────────────────────────────────────────────────────────
class _BudgetContent extends StatelessWidget {
  final TextTheme textTheme;
  const _BudgetContent({super.key, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Overall Budget
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(40),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 40,
                  offset: Offset(0, 10),
                  spreadRadius: -10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Budget', style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Rp 10.000.000', style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -0.5)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Icon(Icons.pie_chart, color: Colors.black87, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Remaining', style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
                    Text('Rp 2.500.000', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.75,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('75% Used', style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Categories', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text('Tambah', style: textTheme.labelMedium?.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
            child: Column(
              children: [
                _buildCategoryCard(context, name: 'Food & Drink', spentAmt: 'Rp 4.500.000', leftAmt: 'Rp 500.000', totalAmt: 'Rp 5.000.000', progress: 0.9, icon: Icons.restaurant, iconColor: Colors.orange.shade600, iconBgColor: Colors.orange.shade100),
                _buildCategoryCard(context, name: 'Transport', spentAmt: 'Rp 1.200.000', leftAmt: 'Rp 800.000', totalAmt: 'Rp 2.000.000', progress: 0.6, icon: Icons.directions_car, iconColor: Colors.blue.shade600, iconBgColor: Colors.blue.shade100),
                _buildCategoryCard(context, name: 'Entertainment', spentAmt: 'Rp 800.000', leftAmt: 'Rp 700.000', totalAmt: 'Rp 1.500.000', progress: 0.53, icon: Icons.movie, iconColor: Colors.purple.shade600, iconBgColor: Colors.purple.shade100),
                _buildCategoryCard(context, name: 'Shopping', spentAmt: 'Rp 1.000.000', leftAmt: 'Rp 500.000', totalAmt: 'Rp 1.500.000', progress: 0.66, icon: Icons.shopping_bag, iconColor: Colors.pink.shade600, iconBgColor: Colors.pink.shade100),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl * 2),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, {required String name, required String spentAmt, required String leftAmt, required String totalAmt, required double progress, required IconData icon, required Color iconColor, required Color iconBgColor}) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(height: 40, width: 40, decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(name, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      Text(spentAmt, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 4),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Left: $leftAmt', style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                      Text('Total: $totalAmt', style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
                    ]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 6, width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(3)),
            child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: progress, child: Container(decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(3)))),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// GOALS CONTENT
// ─────────────────────────────────────────────────────────
class _GoalsContent extends StatelessWidget {
  final TextTheme textTheme;
  const _GoalsContent({super.key, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Your Saving Goals', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () {},
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
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
                _buildGoalCard(context, name: 'MacBook Pro', timeLeft: '14 months left', tagColor: Colors.grey.shade100, tagTextColor: Colors.grey.shade600, icon: Icons.laptop_mac, progress: 0.75, target: 'Rp 24.000.000', shortfall: 'Rp 6.000.000', saved: 'Rp 18.000.000'),
                _buildGoalCard(context, name: 'Emergency Fund', timeLeft: 'Urgent', tagColor: Colors.red.shade50, tagTextColor: Colors.red.shade600, icon: Icons.health_and_safety, progress: 0.45, target: 'Rp 50.000.000', shortfall: 'Rp 27.500.000', saved: 'Rp 22.500.000'),
                _buildGoalCard(context, name: 'Japan Trip', timeLeft: '8 months left', tagColor: Colors.grey.shade100, tagTextColor: Colors.grey.shade600, icon: Icons.flight, progress: 0.20, target: 'Rp 35.000.000', shortfall: 'Rp 28.000.000', saved: 'Rp 7.000.000'),
                _buildGoalCard(context, name: 'Tesla Model 3', timeLeft: '3 years left', tagColor: Colors.grey.shade100, tagTextColor: Colors.grey.shade600, icon: Icons.directions_car, progress: 0.10, target: 'Rp 800.000.000', shortfall: 'Rp 720.000.000', saved: 'Rp 80.000.000'),
                // Create new goal card
                Container(
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade300)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(height: 56, width: 56, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]), child: const Icon(Icons.add, color: Colors.grey, size: 28)),
                      const SizedBox(height: 12),
                      const Text('Create New Goal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Smart Tip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(24)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 40, width: 40, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: const Icon(Icons.tips_and_updates, color: Colors.black, size: 20)),
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
                            children: const [
                              TextSpan(text: 'Based on your spending, you can save an extra '),
                              TextSpan(text: 'Rp 500.000', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                              TextSpan(text: ' this month by cutting down on coffee expenses.'),
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
    );
  }

  Widget _buildGoalCard(BuildContext context, {required String name, required String timeLeft, required Color tagColor, required Color tagTextColor, required IconData icon, required double progress, required String target, required String shortfall, required String saved}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade100), boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 2))]),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const SizedBox(height: 16),
                SizedBox(
                  height: 80, width: 80,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(value: progress, strokeWidth: 6, backgroundColor: Colors.grey.shade100, color: AppColors.primary, strokeCap: StrokeCap.round),
                      Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 24, color: Colors.grey.shade800), const SizedBox(height: 2), Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))])),
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
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Saved', style: TextStyle(fontSize: 9, color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
                    Text(saved, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ],
            ),
          ),
          Positioned(top: 12, left: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(12)), child: Text(timeLeft, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: tagTextColor)))),
          const Positioned(top: 12, right: 12, child: Icon(Icons.more_horiz, size: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// BILLS CONTENT
// ─────────────────────────────────────────────────────────
class _BillsContent extends StatelessWidget {
  final TextTheme textTheme;
  const _BillsContent({super.key, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
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
                    height: 8, width: double.infinity,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(4)),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft, widthFactor: 0.65,
                      child: Container(decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(4))),
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
            child: Align(alignment: Alignment.centerLeft, child: Text('Upcoming Payments', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
            child: Column(
              children: [
                _buildPaymentCard(title: 'Netflix Premium', dateTag: 'Due in 2 days', dateTagColor: Colors.red.shade50, dateTagTextColor: Colors.red.shade600, dateStr: 'Jan 28', amount: 'Rp 186.000', actionLabel: 'Pay Now', actionColor: AppColors.primaryDark, icon: Icons.movie, iconBgColor: Colors.black, iconColor: Colors.red.shade600),
                _buildPaymentCard(title: 'Spotify Family', dateTag: 'Due in 5 days', dateTagColor: Colors.orange.shade50, dateTagTextColor: Colors.orange.shade600, dateStr: 'Jan 31', amount: 'Rp 86.000', actionLabel: 'Pay Now', actionColor: AppColors.primaryDark, icon: Icons.graphic_eq, iconBgColor: Colors.green.shade500, iconColor: Colors.white),
                _buildPaymentCard(title: 'IndiHome Fiber', dateTag: 'Feb 05', dateTagColor: Colors.grey.shade100, dateTagTextColor: Colors.grey.shade500, dateStr: null, amount: 'Rp 350.000', actionLabel: 'Auto-pay on', actionColor: Colors.grey.shade400, icon: Icons.router, iconBgColor: Colors.blue.shade600, iconColor: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Paid this month
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
            child: Align(alignment: Alignment.centerLeft, child: Text('Paid this month', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
            child: Opacity(
              opacity: 0.6,
              child: Column(
                children: [
                  _buildPaidCard(title: 'Water Bill (PDAM)', dateStr: 'Paid on Jan 15', amount: 'Rp 125.000', icon: Icons.water_drop),
                  _buildPaidCard(title: 'Electricity (PLN)', dateStr: 'Paid on Jan 10', amount: 'Rp 539.000', icon: Icons.bolt),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl * 2),
        ],
      ),
    );
  }

  Widget _buildPaymentCard({required String title, required String dateTag, required Color dateTagColor, required Color dateTagTextColor, String? dateStr, required String amount, required String actionLabel, required Color actionColor, required IconData icon, required Color iconBgColor, required Color iconColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade100), boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 2))]),
      child: Row(
        children: [
          Container(height: 48, width: 48, decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: iconColor, size: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Row(children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: dateTagColor, borderRadius: BorderRadius.circular(4)), child: Text(dateTag, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: dateTagTextColor))),
                  if (dateStr != null) ...[const SizedBox(width: 6), Text(dateStr, style: TextStyle(fontSize: 10, color: Colors.grey.shade400))]
                ]),
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

  Widget _buildPaidCard({required String title, required String dateStr, required String amount, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        children: [
          Container(height: 40, width: 40, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade100)), child: Icon(icon, color: Colors.grey.shade400, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey.shade700)), const SizedBox(height: 2), Text(dateStr, style: TextStyle(fontSize: 10, color: Colors.grey.shade400))])),
          Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
