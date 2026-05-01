import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
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

  DateTime _targetDate = DateTime.now().add(const Duration(days: 90));
  String _priority = 'Needs';
  IconData _selectedIcon = Icons.star;

  final List<IconData> _availableIcons = [
    Icons.star, Icons.laptop_mac, Icons.health_and_safety, Icons.flight,
    Icons.directions_car, Icons.home, Icons.phone_iphone, Icons.school,
    Icons.shopping_bag, Icons.sports_esports, Icons.camera_alt, Icons.diamond,
  ];

  final _priorityOptions = [
    {'label': 'Urgent', 'icon': Icons.priority_high, 'color': Colors.red},
    {'label': 'Needs', 'icon': Icons.check_circle, 'color': Colors.orange},
    {'label': 'Wants', 'icon': Icons.favorite, 'color': Colors.blue},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _targetAmountController = TextEditingController();

    if (widget.goalId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final goals = ref.read(goalsProvider);
        final goal = goals.firstWhere((g) => g.id == widget.goalId, orElse: () => goals.first);
        setState(() {
          _nameController.text = goal.name;
          _targetAmountController.text = goal.targetAmount.toInt().toString();
          _targetDate = goal.targetDate;
          _priority = goal.priority;
          _selectedIcon = goal.icon;
        });
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      final targetAmount = double.tryParse(_targetAmountController.text.replaceAll('.', '')) ?? 0;

      Color tagColor = Colors.grey.shade100;
      Color tagTextColor = Colors.grey.shade600;
      if (_priority == 'Urgent') {
        tagColor = Colors.red.shade50;
        tagTextColor = Colors.red.shade600;
      } else if (_priority == 'Wants') {
        tagColor = Colors.blue.shade50;
        tagTextColor = Colors.blue.shade600;
      }

      if (widget.goalId == null) {
        // Add mode — create with 0 savedAmount, no contributions
        final newGoal = GoalModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          targetAmount: targetAmount,
          savedAmount: 0,
          targetDate: _targetDate,
          icon: _selectedIcon,
          tagColor: tagColor,
          tagTextColor: tagTextColor,
          priority: _priority,
          sourceAsset: '',
        );
        ref.read(goalsProvider.notifier).addGoal(newGoal);
      } else {
        // Edit mode — preserve existing savedAmount and contributions
        final existing = ref.read(goalsProvider).firstWhere((g) => g.id == widget.goalId);
        final updated = existing.copyWith(
          name: _nameController.text,
          targetAmount: targetAmount,
          targetDate: _targetDate,
          icon: _selectedIcon,
          tagColor: tagColor,
          tagTextColor: tagTextColor,
          priority: _priority,
        );
        ref.read(goalsProvider.notifier).updateGoal(updated);
      }

      context.pop();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );
    if (picked != null && picked != _targetDate) {
      setState(() => _targetDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.goalId != null;
    final daysLeft = _targetDate.difference(DateTime.now()).inDays;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Goal' : 'Buat Goal Baru',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Hapus Goal?'),
                    content: const Text('Yakin mau hapus goal ini? Aksi ini tidak bisa dibatalkan.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                      TextButton(
                        onPressed: () {
                          ref.read(goalsProvider.notifier).removeGoal(widget.goalId!);
                          Navigator.pop(ctx);
                          context.pop();
                        },
                        child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Icon picker
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 72, width: 72,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary.withValues(alpha: 0.3), AppColors.primaryLight],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_selectedIcon, size: 36, color: AppColors.primaryDark),
                    ),
                    const SizedBox(height: 12),
                    Text('Pilih Ikon', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey.shade500, letterSpacing: 0.5)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _availableIcons.map((icon) {
                        final isSelected = _selectedIcon == icon;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedIcon = icon),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.black : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(icon, size: 22, color: isSelected ? Colors.white : Colors.grey.shade500),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Name + Target Amount + Target Date
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Nama Goal'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration('Contoh: MacBook Pro, Yamaha NMAX'),
                      validator: (v) => v == null || v.isEmpty ? 'Nama goal wajib diisi' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Target Nominal'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _targetAmountController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('24000000', prefix: 'Rp '),
                      validator: (v) => v == null || v.isEmpty ? 'Nominal wajib diisi' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Target Tanggal'),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade500),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                DateFormat('d MMMM yyyy').format(_targetDate),
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: daysLeft < 30 ? Colors.red.shade50 : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$daysLeft hari lagi',
                                style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w700,
                                  color: daysLeft < 30 ? Colors.red.shade600 : Colors.green.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Priority section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Prioritas'),
                    const SizedBox(height: 12),
                    Row(
                      children: _priorityOptions.map((opt) {
                        final isSelected = _priority == opt['label'];
                        final color = opt['color'] as Color;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _priority = opt['label'] as String),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? color : Colors.grey.shade200,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(opt['icon'] as IconData, size: 22, color: isSelected ? color : Colors.grey.shade400),
                                  const SizedBox(height: 6),
                                  Text(
                                    opt['label'] as String,
                                    style: TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.w700,
                                      color: isSelected ? color : Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Save button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
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
                      isEditing ? 'Simpan Perubahan' : 'Buat Goal',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey.shade700, letterSpacing: 0.2));
  }

  InputDecoration _inputDecoration(String hint, {String? prefix}) {
    return InputDecoration(
      hintText: hint, prefixText: prefix,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      prefixStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      filled: true, fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primaryDark, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
