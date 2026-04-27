import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/finance_tabs.dart';
import '../providers/finance_providers.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
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
            child: _buildContent(textTheme),
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
class _BudgetContent extends ConsumerWidget {
  final TextTheme textTheme;
  const _BudgetContent({super.key, required this.textTheme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetsProvider);

    double totalBudget = 0;
    double totalSpent = 0;
    for (var b in budgets) {
      totalBudget += b.totalAmount;
      totalSpent += b.spentAmount;
    }

    final remaining = totalBudget - totalSpent;
    final progress = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;

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
                        Text('Rp ${totalBudget.toInt()}', style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -0.5)),
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
                    Text('Rp ${remaining.toInt()}', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
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
                    widthFactor: progress,
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
                  child: Text('${(progress * 100).toInt()}% Used', style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
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
                TextButton.icon(
                  onPressed: () => context.push('/budget/add'),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  icon: const Icon(Icons.add, color: Colors.black, size: 18),
                  label: Text('Add new budget', style: textTheme.labelMedium?.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: budgets.length,
              itemBuilder: (context, index) {
                final budget = budgets[index];
                final budgetProgress = budget.totalAmount > 0 ? (budget.spentAmount / budget.totalAmount).clamp(0.0, 1.0) : 0.0;
                
                return Dismissible(
                  key: Key(budget.id),
                  background: Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.centerLeft,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.centerRight,
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      // Swipe Left (Edit)
                      context.push('/budget/edit/${budget.id}');
                      return false; // Don't dismiss
                    } else if (direction == DismissDirection.startToEnd) {
                      // Swipe Right (Delete)
                      return true; // Dismiss and delete
                    }
                    return false;
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.startToEnd) {
                      ref.read(budgetsProvider.notifier).removeBudget(budget.id);
                    }
                  },
                  child: _buildCategoryCard(
                    context, 
                    name: budget.name, 
                    spentAmt: 'Rp ${budget.spentAmount.toInt()}', 
                    leftAmt: 'Rp ${(budget.totalAmount - budget.spentAmount).toInt()}', 
                    totalAmt: 'Rp ${budget.totalAmount.toInt()}', 
                    progress: budgetProgress, 
                    icon: budget.icon, 
                    iconColor: budget.iconColor, 
                    iconBgColor: budget.iconBgColor
                  ),
                );
              },
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
class _GoalsContent extends ConsumerWidget {
  final TextTheme textTheme;
  const _GoalsContent({super.key, required this.textTheme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);

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
                  onPressed: () => context.push('/goal/add'),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  icon: const Icon(Icons.add, color: Colors.black, size: 18),
                  label: Text('New Goal', style: textTheme.labelMedium?.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Goals Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.72,
              ),
              itemCount: goals.length + 1, // +1 for the Add New button
              itemBuilder: (context, index) {
                if (index == goals.length) {
                  return GestureDetector(
                    onTap: () => context.push('/goal/add'),
                    child: Container(
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
                  );
                }

                final goal = goals[index];
                final progress = goal.targetAmount > 0 ? (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0) : 0.0;
                final isComplete = progress >= 1.0;
                
                final now = DateTime.now();
                final daysLeft = goal.targetDate.difference(now).inDays;
                final timeLeftStr = isComplete ? 'Complete' : (daysLeft > 30 ? '${daysLeft ~/ 30} months left' : '$daysLeft days left');

                return GestureDetector(
                  onTap: () => context.push('/goal/edit/${goal.id}'),
                  child: _buildGoalCard(
                    context, 
                    name: goal.name, 
                    timeLeft: timeLeftStr, 
                    tagColor: isComplete ? Colors.green.shade50 : goal.tagColor, 
                    tagTextColor: isComplete ? Colors.green.shade600 : goal.tagTextColor, 
                    icon: goal.icon, 
                    progress: progress, 
                    target: 'Rp ${goal.targetAmount.toInt()}', 
                    shortfall: isComplete ? 'Done' : 'Rp ${(goal.targetAmount - goal.savedAmount).toInt()}', 
                    saved: 'Rp ${goal.savedAmount.toInt()}'
                  ),
                );
              },
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
                Text(shortfall == 'Done' ? 'Complete' : 'Kurang $shortfall', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: shortfall == 'Done' ? Colors.green : Colors.red)),
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
class _BillsContent extends ConsumerWidget {
  final TextTheme textTheme;
  const _BillsContent({super.key, required this.textTheme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bills = ref.watch(billsProvider);

    double totalBillsAmount = 0;
    double paidAmount = 0;
    for (var b in bills) {
      totalBillsAmount += b.amount;
      if (b.isPaid) paidAmount += b.amount;
    }

    final remaining = totalBillsAmount - paidAmount;
    final progress = totalBillsAmount > 0 ? (paidAmount / totalBillsAmount).clamp(0.0, 1.0) : 0.0;
    
    final upcomingBills = bills.where((b) => !b.isPaid).toList();
    final paidBills = bills.where((b) => b.isPaid).toList();

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
                          Text(totalBillsAmount.toInt().toString(), style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -0.5)),
                        ],
                      ),
                      Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
                      widthFactor: progress,
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
                      Text('Paid: Rp ${paidAmount.toInt()}', style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                      Text('Remaining: Rp ${remaining.toInt()}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          // Upcoming Payments Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Upcoming Payments', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () => context.push('/bill/add'),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  icon: const Icon(Icons.add, color: Colors.black, size: 18),
                  label: Text('Add new bills', style: textTheme.labelMedium?.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
            child: Column(
              children: upcomingBills.map((bill) {
                final daysLeft = bill.dueDate != null ? bill.dueDate!.difference(DateTime.now()).inDays : 0;
                String dateTag = bill.dueDate != null ? (daysLeft >= 0 ? 'Due in $daysLeft days' : 'Overdue by ${daysLeft.abs()} days') : 'No due date';
                Color dateTagColor = daysLeft <= 2 ? Colors.red.shade50 : Colors.orange.shade50;
                Color dateTagTextColor = daysLeft <= 2 ? Colors.red.shade600 : Colors.orange.shade600;

                return Dismissible(
                  key: Key(bill.id),
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(24)),
                    alignment: Alignment.centerLeft,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(24)),
                    alignment: Alignment.centerRight,
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      context.push('/bill/edit/${bill.id}');
                      return false;
                    } else if (direction == DismissDirection.startToEnd) {
                      return true;
                    }
                    return false;
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.startToEnd) {
                      ref.read(billsProvider.notifier).removeBill(bill.id);
                    }
                  },
                  child: _buildPaymentCard(
                    title: bill.name,
                    dateTag: dateTag,
                    dateTagColor: dateTagColor,
                    dateTagTextColor: dateTagTextColor,
                    dateStr: bill.dueDate != null ? '${bill.dueDate!.day}/${bill.dueDate!.month}' : null,
                    amount: 'Rp ${bill.amount.toInt()}',
                    actionLabel: bill.isAutoPay ? 'Auto-pay on' : 'Pay Now',
                    actionColor: bill.isAutoPay ? Colors.grey.shade400 : AppColors.primaryDark,
                    icon: bill.icon,
                    iconBgColor: bill.iconBgColor,
                    iconColor: bill.iconColor,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Paid this month
          if (paidBills.isNotEmpty) ...[
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
                  children: paidBills.map((bill) {
                    return Dismissible(
                      key: Key(bill.id),
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(24)),
                        alignment: Alignment.centerLeft,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(24)),
                        alignment: Alignment.centerRight,
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          context.push('/bill/edit/${bill.id}');
                          return false;
                        } else if (direction == DismissDirection.startToEnd) {
                          return true;
                        }
                        return false;
                      },
                      onDismissed: (direction) {
                        if (direction == DismissDirection.startToEnd) {
                          ref.read(billsProvider.notifier).removeBill(bill.id);
                        }
                      },
                      child: _buildPaidCard(
                        title: bill.name,
                        dateStr: bill.dueDate != null ? 'Paid on ${bill.dueDate!.day}/${bill.dueDate!.month}' : 'Paid',
                        amount: 'Rp ${bill.amount.toInt()}',
                        icon: bill.icon,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl * 2),
          ]
        ],
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
