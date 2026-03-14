import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class TransactionEntryScreen extends StatefulWidget {
  const TransactionEntryScreen({super.key});

  @override
  State<TransactionEntryScreen> createState() => _TransactionEntryScreenState();
}

class _TransactionEntryScreenState extends State<TransactionEntryScreen> {
  String _type = 'Pengeluaran';
  String _date = 'Hari Ini';
  int _selectedWallet = 1; // 0=BNI, 1=Cash, 2=Stockbit
  String _category = 'Makanan & minuman';
  String _amount = '0';
  final _notesController = TextEditingController();

  final _wallets = [
    {'name': 'BNI Mobile', 'icon': Icons.account_balance},
    {'name': 'Cash', 'icon': Icons.attach_money},
    {'name': 'Stockbit', 'icon': Icons.show_chart},
  ];

  final _categories = [
    'Makanan & minuman',
    'Transport',
    'Belanja',
    'Hiburan',
    'Tagihan',
    'Pendidikan',
    'Kesehatan',
    'Lainnya',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  // Type pill
                  GestureDetector(
                    onTap: () => _showTypePicker(),
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
                              color: _type == 'Pengeluaran' ? Colors.red.shade400 : Colors.green.shade400,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _type == 'Pengeluaran' ? Icons.arrow_upward : Icons.arrow_downward,
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
                            Expanded(child: Text(_date, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14))),
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Coba', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ),

            // Amount display
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: () => _showAmountInput(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Rp', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black.withValues(alpha: 0.4))),
                      const SizedBox(height: 4),
                      Text(
                        _amount == '0' ? '0' : _formatAmount(_amount),
                        style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -2),
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

            // Bottom form sheet
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  const SizedBox(height: 12),
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 16),

                  // Wallet selector
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _wallets.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final selected = _selectedWallet == index;
                          final wallet = _wallets[index];
                          return GestureDetector(
                            onTap: () => setState(() => _selectedWallet = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: selected ? Colors.black : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(wallet['icon'] as IconData, size: 16, color: selected ? Colors.white : Colors.grey.shade600),
                                  const SizedBox(width: 6),
                                  Text(
                                    wallet['name'] as String,
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category selector
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: () => _showCategoryPicker(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
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
                  const SizedBox(height: 12),

                  // Notes
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
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
                            maxLines: 3,
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
                  const SizedBox(height: 16),

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
          ],
        ),
      ),
    );
  }

  void _showTypePicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.arrow_upward, color: Colors.red.shade400),
              title: const Text('Pengeluaran'),
              onTap: () { setState(() => _type = 'Pengeluaran'); Navigator.pop(ctx); },
            ),
            ListTile(
              leading: Icon(Icons.arrow_downward, color: Colors.green.shade400),
              title: const Text('Pemasukan'),
              onTap: () { setState(() => _type = 'Pemasukan'); Navigator.pop(ctx); },
            ),
            ListTile(
              leading: Icon(Icons.swap_horiz, color: Colors.blue.shade400),
              title: const Text('Transfer'),
              onTap: () { setState(() => _type = 'Transfer'); Navigator.pop(ctx); },
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      if (picked.day == now.day && picked.month == now.month && picked.year == now.year) {
        setState(() => _date = 'Hari Ini');
      } else {
        setState(() => _date = '${picked.day}/${picked.month}/${picked.year}');
      }
    }
  }

  void _showAmountInput() {
    final controller = TextEditingController(text: _amount == '0' ? '' : _amount);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                prefixText: 'Rp ',
                prefixStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _amount = controller.text.isEmpty ? '0' : controller.text);
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
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
