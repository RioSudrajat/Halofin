import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../budget/presentation/providers/finance_providers.dart';

class AddEditBillScreen extends ConsumerStatefulWidget {
  final String? billId;

  const AddEditBillScreen({super.key, this.billId});

  @override
  ConsumerState<AddEditBillScreen> createState() => _AddEditBillScreenState();
}

class _AddEditBillScreenState extends ConsumerState<AddEditBillScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _isAutoPay = false;
  bool _isPaid = false;
  IconData _selectedIcon = Icons.receipt;
  
  final List<IconData> _availableIcons = [
    Icons.receipt, Icons.movie, Icons.graphic_eq, Icons.router, 
    Icons.water_drop, Icons.bolt, Icons.credit_card, Icons.phone
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _amountController = TextEditingController();

    if (widget.billId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final bills = ref.read(billsProvider);
        final bill = bills.firstWhere((b) => b.id == widget.billId, orElse: () => bills.first);
        
        setState(() {
          _nameController.text = bill.name;
          _amountController.text = bill.amount.toInt().toString();
          if (bill.dueDate != null) _dueDate = bill.dueDate!;
          _isAutoPay = bill.isAutoPay;
          _isPaid = bill.isPaid;
          _selectedIcon = bill.icon;
        });
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveBill() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text) ?? 0;
      
      final newBill = BillModel(
        id: widget.billId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        amount: amount,
        dueDate: _dueDate,
        isAutoPay: _isAutoPay,
        isPaid: _isPaid,
        icon: _selectedIcon,
        iconColor: Colors.white,
        iconBgColor: Colors.blue.shade600, // Using default color for simplicity
      );

      if (widget.billId == null) {
        ref.read(billsProvider.notifier).addBill(newBill);
      } else {
        ref.read(billsProvider.notifier).updateBill(newBill);
      }
      
      context.pop();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isEditing = widget.billId != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Bill' : 'Add New Bill',
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
                ref.read(billsProvider.notifier).removeBill(widget.billId!);
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
                          color: Colors.blue.shade600,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(_selectedIcon, size: 40, color: Colors.white),
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
                                  color: isSelected ? Colors.blue.shade600 : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
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
                Text('Bill Name', style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Netflix Premium',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryDark)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter a bill name' : null,
                ),
                const SizedBox(height: AppSpacing.md),

                Text('Amount (Rp)', style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '186000',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryDark)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter bill amount' : null,
                ),
                const SizedBox(height: AppSpacing.md),

                Text('Due Date', style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
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
                        Text('${_dueDate.day}/${_dueDate.month}/${_dueDate.year}'),
                        const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Switches
                SwitchListTile(
                  title: Text('Auto-pay', style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Text('Automatically pay when due', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  value: _isAutoPay,
                  activeColor: AppColors.primaryDark,
                  onChanged: (val) => setState(() => _isAutoPay = val),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: Text('Mark as Paid', style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Text('This bill has already been paid', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  value: _isPaid,
                  activeColor: AppColors.primaryDark,
                  onChanged: (val) => setState(() => _isPaid = val),
                  contentPadding: EdgeInsets.zero,
                ),

                const SizedBox(height: AppSpacing.xxl * 2),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveBill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      isEditing ? 'Save Changes' : 'Create Bill',
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
