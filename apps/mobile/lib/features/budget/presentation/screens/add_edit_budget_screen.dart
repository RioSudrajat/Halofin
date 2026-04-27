import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/finance_providers.dart';

class AddEditBudgetScreen extends ConsumerStatefulWidget {
  final String? budgetId;

  const AddEditBudgetScreen({super.key, this.budgetId});

  @override
  ConsumerState<AddEditBudgetScreen> createState() => _AddEditBudgetScreenState();
}

class _AddEditBudgetScreenState extends ConsumerState<AddEditBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _totalAmountController;
  late TextEditingController _spentAmountController;
  
  IconData _selectedIcon = Icons.restaurant;
  Color _selectedColor = Colors.orange;
  
  final List<IconData> _availableIcons = [
    Icons.restaurant, Icons.directions_car, Icons.movie, Icons.shopping_bag, 
    Icons.medical_services, Icons.bolt, Icons.pets, Icons.card_giftcard
  ];

  final List<Color> _availableColors = [
    Colors.orange, Colors.blue, Colors.purple, Colors.pink, 
    Colors.green, Colors.teal, Colors.red, Colors.brown
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _totalAmountController = TextEditingController();
    _spentAmountController = TextEditingController(text: '0');

    if (widget.budgetId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final budgets = ref.read(budgetsProvider);
        final budget = budgets.firstWhere((b) => b.id == widget.budgetId, orElse: () => budgets.first);
        
        setState(() {
          _nameController.text = budget.name;
          _totalAmountController.text = budget.totalAmount.toInt().toString();
          _spentAmountController.text = budget.spentAmount.toInt().toString();
          _selectedIcon = budget.icon;
          // approximate color match
          _selectedColor = _availableColors.firstWhere((c) => c.value == budget.iconColor.value, orElse: () => _availableColors.first);
        });
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalAmountController.dispose();
    _spentAmountController.dispose();
    super.dispose();
  }

  void _saveBudget() {
    if (_formKey.currentState!.validate()) {
      final totalAmount = double.tryParse(_totalAmountController.text) ?? 0;
      final spentAmount = double.tryParse(_spentAmountController.text) ?? 0;
      
      final newBudget = BudgetCategoryModel(
        id: widget.budgetId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        totalAmount: totalAmount,
        spentAmount: spentAmount,
        icon: _selectedIcon,
        iconColor: _selectedColor,
        iconBgColor: _selectedColor.withValues(alpha: 0.2),
      );

      if (widget.budgetId == null) {
        ref.read(budgetsProvider.notifier).addBudget(newBudget);
      } else {
        ref.read(budgetsProvider.notifier).updateBudget(newBudget);
      }
      
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isEditing = widget.budgetId != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Budget' : 'Add New Budget',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                ref.read(budgetsProvider.notifier).removeBudget(widget.budgetId!);
                context.pop();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.edgeMargin),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon & Color Preview
                Center(
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: _selectedColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_selectedIcon, size: 40, color: _selectedColor),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Icon Selection
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: _availableIcons.length,
                    itemBuilder: (context, index) {
                      final icon = _availableIcons[index];
                      final isSelected = _selectedIcon == icon;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIcon = icon),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.grey.shade800 : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade600),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                
                // Color Selection
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: _availableColors.length,
                    itemBuilder: (context, index) {
                      final color = _availableColors[index];
                      final isSelected = _selectedColor == color;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Form Fields
                Text('Category Name', style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Food & Drink',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryDark)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter a category name' : null,
                ),
                const SizedBox(height: AppSpacing.md),

                Text('Total Amount (Rp)', style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _totalAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '5000000',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryDark)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter total amount' : null,
                ),
                const SizedBox(height: AppSpacing.md),

                Text('Spent Amount (Rp) [For Demo]', style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _spentAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '0',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryDark)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xxl * 2),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveBudget,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      isEditing ? 'Save Changes' : 'Create Budget',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
