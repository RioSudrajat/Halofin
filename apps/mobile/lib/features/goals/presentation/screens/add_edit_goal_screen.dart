import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../budget/presentation/providers/finance_providers.dart';

class AddEditGoalScreen extends ConsumerStatefulWidget {
  final String? goalId;

  const AddEditGoalScreen({super.key, this.goalId});

  @override
  ConsumerState<AddEditGoalScreen> createState() => _AddEditGoalScreenState();
}

class _AddEditGoalScreenState extends ConsumerState<AddEditGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _targetAmountController;
  late TextEditingController _savedAmountController;
  
  DateTime _targetDate = DateTime.now().add(const Duration(days: 30));
  String _priority = 'Needs';
  String _sourceAsset = 'Liquid';
  IconData _selectedIcon = Icons.star;
  
  final List<IconData> _availableIcons = [
    Icons.star, Icons.laptop_mac, Icons.health_and_safety, Icons.flight, 
    Icons.directions_car, Icons.home, Icons.phone_iphone, Icons.school
  ];
  
  final List<String> _priorities = ['Urgent', 'Needs', 'Wants'];
  final List<String> _sourceAssets = ['Liquid', 'Deposit', 'Mutual Fund', 'Stock'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _targetAmountController = TextEditingController();
    _savedAmountController = TextEditingController(text: '0');

    // If editing, populate the fields
    if (widget.goalId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final goals = ref.read(goalsProvider);
        final goal = goals.firstWhere((g) => g.id == widget.goalId, orElse: () => goals.first);
        
        setState(() {
          _nameController.text = goal.name;
          _targetAmountController.text = goal.targetAmount.toInt().toString();
          _savedAmountController.text = goal.savedAmount.toInt().toString();
          _targetDate = goal.targetDate;
          _priority = goal.priority;
          _sourceAsset = goal.sourceAsset;
          _selectedIcon = goal.icon;
        });
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _savedAmountController.dispose();
    super.dispose();
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      final targetAmount = double.tryParse(_targetAmountController.text) ?? 0;
      final savedAmount = double.tryParse(_savedAmountController.text) ?? 0;
      
      Color tagColor = Colors.grey.shade100;
      Color tagTextColor = Colors.grey.shade600;
      if (_priority == 'Urgent') {
        tagColor = Colors.red.shade50;
        tagTextColor = Colors.red.shade600;
      } else if (_priority == 'Wants') {
        tagColor = Colors.blue.shade50;
        tagTextColor = Colors.blue.shade600;
      }

      final newGoal = GoalModel(
        id: widget.goalId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        targetAmount: targetAmount,
        savedAmount: savedAmount,
        targetDate: _targetDate,
        icon: _selectedIcon,
        tagColor: tagColor,
        tagTextColor: tagTextColor,
        priority: _priority,
        sourceAsset: _sourceAsset,
      );

      if (widget.goalId == null) {
        ref.read(goalsProvider.notifier).addGoal(newGoal);
      } else {
        ref.read(goalsProvider.notifier).updateGoal(newGoal);
      }
      
      context.pop();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isEditing = widget.goalId != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Goal' : 'Add New Goal',
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
                ref.read(goalsProvider.notifier).removeGoal(widget.goalId!);
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
                // Icon Selection
                Center(
                  child: Column(
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_selectedIcon, size: 40, color: AppColors.primaryDark),
                      ),
                      const SizedBox(height: AppSpacing.sm),
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
                                  color: isSelected ? AppColors.primary : Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade600),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Form Fields
                Text('Goal Name', style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. MacBook Pro',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryDark)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter a goal name' : null,
                ),
                const SizedBox(height: AppSpacing.md),

                Text('Target Amount (Rp)', style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _targetAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '24000000',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryDark)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter target amount' : null,
                ),
                const SizedBox(height: AppSpacing.md),

                Text('Saved Amount (Rp) [For Demo]', style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _savedAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '0',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryDark)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Priority', style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _priority,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            items: _priorities.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              if (newValue != null) setState(() => _priority = newValue);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Source Asset', style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _sourceAsset,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            items: _sourceAssets.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              if (newValue != null) setState(() => _sourceAsset = newValue);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                Text('Target Date', style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${_targetDate.day}/${_targetDate.month}/${_targetDate.year}'),
                        const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xxl * 2),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveGoal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      isEditing ? 'Save Changes' : 'Create Goal',
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
