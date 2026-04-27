import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- MODELS ---

class GoalModel {
  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime targetDate;
  final IconData icon;
  final Color tagColor;
  final Color tagTextColor;
  final String priority; // Urgent, Needs, Wants
  final String sourceAsset; // Legacy label for display
  /// Tracks contributions from multiple wallets: walletId -> amount
  final Map<String, double> contributions;

  GoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.targetDate,
    required this.icon,
    required this.tagColor,
    required this.tagTextColor,
    required this.priority,
    required this.sourceAsset,
    this.contributions = const {},
  });

  GoalModel copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? savedAmount,
    DateTime? targetDate,
    IconData? icon,
    Color? tagColor,
    Color? tagTextColor,
    String? priority,
    String? sourceAsset,
    Map<String, double>? contributions,
  }) {
    return GoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      targetDate: targetDate ?? this.targetDate,
      icon: icon ?? this.icon,
      tagColor: tagColor ?? this.tagColor,
      tagTextColor: tagTextColor ?? this.tagTextColor,
      priority: priority ?? this.priority,
      sourceAsset: sourceAsset ?? this.sourceAsset,
      contributions: contributions ?? this.contributions,
    );
  }
}

class BudgetCategoryModel {
  final String id;
  final String name;
  final double totalAmount;
  final double spentAmount;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  BudgetCategoryModel({
    required this.id,
    required this.name,
    required this.totalAmount,
    required this.spentAmount,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  BudgetCategoryModel copyWith({
    String? id,
    String? name,
    double? totalAmount,
    double? spentAmount,
    IconData? icon,
    Color? iconColor,
    Color? iconBgColor,
  }) {
    return BudgetCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      totalAmount: totalAmount ?? this.totalAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      iconBgColor: iconBgColor ?? this.iconBgColor,
    );
  }
}

class BillModel {
  final String id;
  final String name;
  final DateTime? dueDate;
  final double amount;
  final bool isAutoPay;
  final bool isPaid;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  BillModel({
    required this.id,
    required this.name,
    this.dueDate,
    required this.amount,
    required this.isAutoPay,
    required this.isPaid,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  BillModel copyWith({
    String? id,
    String? name,
    DateTime? dueDate,
    double? amount,
    bool? isAutoPay,
    bool? isPaid,
    IconData? icon,
    Color? iconColor,
    Color? iconBgColor,
  }) {
    return BillModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dueDate: dueDate ?? this.dueDate,
      amount: amount ?? this.amount,
      isAutoPay: isAutoPay ?? this.isAutoPay,
      isPaid: isPaid ?? this.isPaid,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      iconBgColor: iconBgColor ?? this.iconBgColor,
    );
  }
}

// --- NOTIFIERS ---

class GoalsNotifier extends Notifier<List<GoalModel>> {
  @override
  List<GoalModel> build() {
    return [
      GoalModel(
        id: 'g1',
        name: 'MacBook Pro',
        targetAmount: 24000000,
        savedAmount: 18000000,
        targetDate: DateTime.now().add(const Duration(days: 425)),
        icon: Icons.laptop_mac,
        tagColor: Colors.grey.shade100,
        tagTextColor: Colors.grey.shade600,
        priority: 'Wants',
        sourceAsset: 'Liquid',
      ),
      GoalModel(
        id: 'g2',
        name: 'Emergency Fund',
        targetAmount: 50000000,
        savedAmount: 22500000,
        targetDate: DateTime.now().add(const Duration(days: 10)),
        icon: Icons.health_and_safety,
        tagColor: Colors.red.shade50,
        tagTextColor: Colors.red.shade600,
        priority: 'Urgent',
        sourceAsset: 'Deposit',
      ),
      GoalModel(
        id: 'g3',
        name: 'Japan Trip',
        targetAmount: 35000000,
        savedAmount: 7000000,
        targetDate: DateTime.now().add(const Duration(days: 240)),
        icon: Icons.flight,
        tagColor: Colors.grey.shade100,
        tagTextColor: Colors.grey.shade600,
        priority: 'Needs',
        sourceAsset: 'Mutual Fund',
      ),
      GoalModel(
        id: 'g4',
        name: 'Tesla Model 3',
        targetAmount: 800000000,
        savedAmount: 80000000,
        targetDate: DateTime.now().add(const Duration(days: 1095)),
        icon: Icons.directions_car,
        tagColor: Colors.grey.shade100,
        tagTextColor: Colors.grey.shade600,
        priority: 'Wants',
        sourceAsset: 'Stock',
      ),
    ];
  }

  void addGoal(GoalModel goal) {
    state = [...state, goal];
  }

  void updateGoal(GoalModel updatedGoal) {
    state = [
      for (final goal in state)
        if (goal.id == updatedGoal.id) updatedGoal else goal,
    ];
  }

  void removeGoal(String id) {
    state = state.where((goal) => goal.id != id).toList();
  }

  /// Add savings to a goal from a specific wallet source
  void addSavings(String goalId, String walletId, double amount) {
    state = state.map((goal) {
      if (goal.id == goalId) {
        final newContributions = Map<String, double>.from(goal.contributions);
        newContributions[walletId] = (newContributions[walletId] ?? 0) + amount;
        return goal.copyWith(
          savedAmount: goal.savedAmount + amount,
          contributions: newContributions,
        );
      }
      return goal;
    }).toList();
  }
}

class BudgetsNotifier extends Notifier<List<BudgetCategoryModel>> {
  @override
  List<BudgetCategoryModel> build() {
    return [
      BudgetCategoryModel(
        id: 'b1',
        name: 'Food & Drink',
        totalAmount: 5000000,
        spentAmount: 4500000,
        icon: Icons.restaurant,
        iconColor: Colors.orange.shade600,
        iconBgColor: Colors.orange.shade100,
      ),
      BudgetCategoryModel(
        id: 'b2',
        name: 'Transport',
        totalAmount: 2000000,
        spentAmount: 1200000,
        icon: Icons.directions_car,
        iconColor: Colors.blue.shade600,
        iconBgColor: Colors.blue.shade100,
      ),
      BudgetCategoryModel(
        id: 'b3',
        name: 'Entertainment',
        totalAmount: 1500000,
        spentAmount: 800000,
        icon: Icons.movie,
        iconColor: Colors.purple.shade600,
        iconBgColor: Colors.purple.shade100,
      ),
      BudgetCategoryModel(
        id: 'b4',
        name: 'Shopping',
        totalAmount: 1500000,
        spentAmount: 1000000,
        icon: Icons.shopping_bag,
        iconColor: Colors.pink.shade600,
        iconBgColor: Colors.pink.shade100,
      ),
    ];
  }

  void addBudget(BudgetCategoryModel budget) {
    state = [...state, budget];
  }

  void updateBudget(BudgetCategoryModel updatedBudget) {
    state = [
      for (final budget in state)
        if (budget.id == updatedBudget.id) updatedBudget else budget,
    ];
  }

  void removeBudget(String id) {
    state = state.where((budget) => budget.id != id).toList();
  }
}

class BillsNotifier extends Notifier<List<BillModel>> {
  @override
  List<BillModel> build() {
    return [
      BillModel(
        id: 'bl1',
        name: 'Netflix Premium',
        amount: 186000,
        dueDate: DateTime.now().add(const Duration(days: 2)),
        isAutoPay: false,
        isPaid: false,
        icon: Icons.movie,
        iconColor: Colors.red.shade600,
        iconBgColor: Colors.black,
      ),
      BillModel(
        id: 'bl2',
        name: 'Spotify Family',
        amount: 86000,
        dueDate: DateTime.now().add(const Duration(days: 5)),
        isAutoPay: false,
        isPaid: false,
        icon: Icons.graphic_eq,
        iconColor: Colors.white,
        iconBgColor: Colors.green.shade500,
      ),
      BillModel(
        id: 'bl3',
        name: 'IndiHome Fiber',
        amount: 350000,
        dueDate: DateTime.now().add(const Duration(days: 10)),
        isAutoPay: true,
        isPaid: false,
        icon: Icons.router,
        iconColor: Colors.white,
        iconBgColor: Colors.blue.shade600,
      ),
      BillModel(
        id: 'bl4',
        name: 'Water Bill (PDAM)',
        amount: 125000,
        dueDate: DateTime.now().subtract(const Duration(days: 12)),
        isAutoPay: false,
        isPaid: true,
        icon: Icons.water_drop,
        iconColor: Colors.grey.shade400,
        iconBgColor: Colors.white,
      ),
      BillModel(
        id: 'bl5',
        name: 'Electricity (PLN)',
        amount: 539000,
        dueDate: DateTime.now().subtract(const Duration(days: 17)),
        isAutoPay: false,
        isPaid: true,
        icon: Icons.bolt,
        iconColor: Colors.grey.shade400,
        iconBgColor: Colors.white,
      ),
    ];
  }

  void addBill(BillModel bill) {
    state = [...state, bill];
  }

  void updateBill(BillModel updatedBill) {
    state = [
      for (final bill in state)
        if (bill.id == updatedBill.id) updatedBill else bill,
    ];
  }

  void removeBill(String id) {
    state = state.where((bill) => bill.id != id).toList();
  }
}

// --- PROVIDERS ---

final goalsProvider = NotifierProvider<GoalsNotifier, List<GoalModel>>(GoalsNotifier.new);

final budgetsProvider = NotifierProvider<BudgetsNotifier, List<BudgetCategoryModel>>(BudgetsNotifier.new);

final billsProvider = NotifierProvider<BillsNotifier, List<BillModel>>(BillsNotifier.new);
