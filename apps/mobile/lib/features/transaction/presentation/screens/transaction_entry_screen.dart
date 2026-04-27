import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/models/transaction_model.dart';
import '../../../../core/models/wallet_model.dart';
import '../../../../core/providers/mock_providers.dart';
import '../../../budget/presentation/providers/finance_providers.dart';

class TransactionEntryScreen extends ConsumerStatefulWidget {
  const TransactionEntryScreen({super.key});

  @override
  ConsumerState<TransactionEntryScreen> createState() => _TransactionEntryScreenState();
}

class _TransactionEntryScreenState extends ConsumerState<TransactionEntryScreen> {
  String _type = 'Pengeluaran';
  DateTime _selectedDate = DateTime.now();
  String _dateString = 'Hari Ini';
  String? _selectedWalletId;
  String? _targetWalletId;
  String? _targetGoalId;
  String _category = 'Makanan & minuman';
  final _amountController = TextEditingController(text: '');
  final _amountFocusNode = FocusNode();
  final _notesController = TextEditingController();

  final _categories = [
    'Makanan & minuman', 'Transport', 'Belanja', 'Hiburan',
    'Tagihan', 'Pendidikan', 'Kesehatan', 'Lainnya',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String get _displayAmount {
    final text = _amountController.text.replaceAll('.', '');
    if (text.isEmpty) return '0';
    return _formatAmount(text);
  }

  List<WalletModel> _getFilteredWallets(List<WalletModel> wallets) {
    if (_type == 'Pengeluaran') {
      // Only liquid assets for expenses
      return wallets.where((w) =>
        w.type == 'Bank' || w.type == 'E-Wallet' || w.type == 'Cash'
      ).toList();
    }
    // Income & Transfer: all wallets
    return wallets;
  }

  void _saveTransaction() {
    final amt = double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;
    if (amt <= 0 || _selectedWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal dan dompet harus diisi')),
      );
      return;
    }

    if (_type == 'Transfer' && _targetWalletId == null && _targetGoalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tujuan transfer')),
      );
      return;
    }

    // Volatile asset validation for goal transfers
    if (_type == 'Transfer' && _targetGoalId != null) {
      final wallet = ref.read(walletsProvider).firstWhere((w) => w.id == _selectedWalletId);
      if (wallet.isVolatile && amt != wallet.balance) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aset volatile harus ditransfer seluruhnya ke goals')),
        );
        return;
      }
    }

    final type = _type == 'Pemasukan' ? 'income' : (_type == 'Pengeluaran' ? 'expense' : 'transfer');

    final tx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      walletId: _selectedWalletId!,
      type: type,
      amount: amt,
      category: _type == 'Transfer' ? 'Transfer' : _category,
      date: _selectedDate,
      title: _notesController.text.isNotEmpty ? _notesController.text : (_type == 'Transfer' ? 'Transfer' : _category),
      targetWalletId: _targetWalletId,
      targetGoalId: _targetGoalId,
    );

    ref.read(transactionsProvider.notifier).addTransaction(tx);
    context.go('/transaction/success');
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsProvider);
    final goals = ref.watch(goalsProvider);
    final filteredWallets = _getFilteredWallets(wallets);

    if (_selectedWalletId == null && filteredWallets.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedWalletId = filteredWallets.first.id);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.close, color: Colors.black, size: 28),
                  ),
                  const Text('Catat Transaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Upload', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Type and Date pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Type pill — PopupMenuButton inline
                  PopupMenuButton<String>(
                    onSelected: (val) => setState(() {
                      _type = val;
                      _targetWalletId = null;
                      _targetGoalId = null;
                      // Reset wallet selection if current one is not in filtered list
                      final filtered = _getFilteredWallets(wallets);
                      if (_selectedWalletId != null && !filtered.any((w) => w.id == _selectedWalletId)) {
                        _selectedWalletId = filtered.isNotEmpty ? filtered.first.id : null;
                      }
                    }),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    offset: const Offset(0, 48),
                    itemBuilder: (_) => [
                      _buildTypeMenuItem('Pengeluaran', Icons.arrow_upward, Colors.red.shade400),
                      _buildTypeMenuItem('Pemasukan', Icons.arrow_downward, Colors.green.shade400),
                      _buildTypeMenuItem('Transfer', Icons.swap_horiz, Colors.blue.shade400),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                              color: _type == 'Pengeluaran' ? Colors.red.shade400 : (_type == 'Transfer' ? Colors.blue.shade400 : Colors.green.shade400),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _type == 'Pengeluaran' ? Icons.arrow_upward : (_type == 'Transfer' ? Icons.swap_horiz : Icons.arrow_downward),
                              size: 14, color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(_type, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(width: 4),
                          const Icon(Icons.expand_more, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Date pill
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showDatePicker(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_dateString, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14))),
                            const Icon(Icons.expand_more, color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // AI banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Text('Coba catat pakai AI, lebih praktis!', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                          const SizedBox(width: 6),
                          Icon(Icons.flash_on, color: Colors.yellow.shade600, size: 16),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child: const Text('Coba', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ),

            // Amount display — direct inline input
            Expanded(
              child: GestureDetector(
                onTap: () => _amountFocusNode.requestFocus(),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Rp', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black.withValues(alpha: 0.4))),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 280,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Hidden text field
                            Opacity(
                              opacity: 0,
                              child: TextField(
                                controller: _amountController,
                                focusNode: _amountFocusNode,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            // Visible formatted display
                            Text(
                              _displayAmount,
                              style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -2),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Duplicate shortcut
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.copy, size: 16, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Duplikat data transaksi yang lalu', style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 16, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bottom form sheet — swipe-to-finish HERE
            GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity != null && details.primaryVelocity! < -300) {
                  _saveTransaction();
                }
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 16),

                    // Transfer mode: source label
                    if (_type == 'Transfer')
                      Padding(
                        padding: const EdgeInsets.only(left: 20, bottom: 6),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('SUMBER DARI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey.shade500, letterSpacing: 0.5)),
                        ),
                      ),

                    // Wallet selector (source)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: filteredWallets.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final wallet = filteredWallets[index];
                            final selected = _selectedWalletId == wallet.id;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedWalletId = wallet.id),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: selected ? Colors.black : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(_getWalletIcon(wallet), size: 16, color: selected ? Colors.white : Colors.grey.shade600),
                                    const SizedBox(width: 6),
                                    Text(wallet.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.grey.shade600)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Transfer target picker
                    if (_type == 'Transfer') ...[
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, bottom: 6),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('TRANSFER KE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey.shade500, letterSpacing: 0.5)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              // Other wallets (exclude source)
                              ...wallets.where((w) => w.id != _selectedWalletId).map((wallet) {
                                final selected = _targetWalletId == wallet.id && _targetGoalId == null;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () => setState(() { _targetWalletId = wallet.id; _targetGoalId = null; }),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                      decoration: BoxDecoration(
                                        color: selected ? Colors.black : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(_getWalletIcon(wallet), size: 16, color: selected ? Colors.white : Colors.grey.shade600),
                                          const SizedBox(width: 6),
                                          Text(wallet.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.grey.shade600)),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              // Goals as targets
                              ...goals.map((goal) {
                                final selected = _targetGoalId == goal.id;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () => setState(() { _targetGoalId = goal.id; _targetWalletId = null; }),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                      decoration: BoxDecoration(
                                        color: selected ? Colors.indigo : Colors.indigo.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: selected ? Colors.indigo : Colors.indigo.shade100),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.flag, size: 16, color: selected ? Colors.white : Colors.indigo.shade400),
                                          const SizedBox(width: 6),
                                          Text(goal.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.indigo.shade400)),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Category selector (not shown for Transfer)
                    if (_type != 'Transfer')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GestureDetector(
                          onTap: () => _showCategoryPicker(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16)),
                            child: Row(
                              children: [
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                                  child: const Icon(Icons.restaurant, size: 18, color: AppColors.primaryDark),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(_category, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                                Icon(Icons.expand_more, color: Colors.grey.shade400),
                              ],
                            ),
                          ),
                        ),
                      ),

                    if (_type != 'Transfer') const SizedBox(height: 12),

                    // Notes
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.notes, size: 16, color: Colors.grey.shade400),
                                const SizedBox(width: 8),
                                Text('CATATAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey.shade400, letterSpacing: 0.5)),
                              ],
                            ),
                            TextField(
                              controller: _notesController,
                              maxLines: 2,
                              decoration: InputDecoration(
                                hintText: 'Tambahkan catatan di sini...',
                                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.only(top: 8),
                              ),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Swipe to finish hint
                    Column(
                      children: [
                        const Icon(Icons.keyboard_arrow_up, size: 20, color: Colors.grey),
                        Text('SWIPE UP TO FINISH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey.shade400, letterSpacing: 1)),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildTypeMenuItem(String label, IconData icon, Color color) {
    return PopupMenuItem(
      value: label,
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  IconData _getWalletIcon(WalletModel wallet) {
    final wType = wallet.type.toLowerCase();
    if (wType == 'bank') return Icons.account_balance;
    if (wType == 'e-wallet') return Icons.account_balance_wallet;
    if (wType == 'cash') return Icons.attach_money;
    if (wType == 'stock' || wType == 'crypto' || wType == 'mutual fund') return Icons.show_chart;
    return Icons.account_balance_wallet;
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context, initialDate: _selectedDate,
      firstDate: DateTime(2024), lastDate: DateTime.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      setState(() {
        _selectedDate = picked;
        _dateString = (picked.day == now.day && picked.month == now.month && picked.year == now.year)
            ? 'Hari Ini' : '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _categories.map((cat) => ListTile(
            title: Text(cat),
            trailing: _category == cat ? const Icon(Icons.check, color: AppColors.primary) : null,
            onTap: () { setState(() => _category = cat); Navigator.pop(ctx); },
          )).toList(),
        ),
      ),
    );
  }

  String _formatAmount(String amount) {
    final num = int.tryParse(amount.replaceAll('.', ''));
    if (num == null) return amount;
    final result = StringBuffer();
    final str = num.toString();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) result.write('.');
      result.write(str[i]);
    }
    return result.toString();
  }
}
