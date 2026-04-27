import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/models/wallet_model.dart';
import '../../../../core/providers/mock_providers.dart';

class ManualWalletEntryScreen extends ConsumerStatefulWidget {
  final String institutionName;
  final String institutionType;

  const ManualWalletEntryScreen({
    super.key,
    required this.institutionName,
    required this.institutionType,
  });

  @override
  ConsumerState<ManualWalletEntryScreen> createState() => _ManualWalletEntryScreenState();
}

class _ManualWalletEntryScreenState extends ConsumerState<ManualWalletEntryScreen> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _returnPercentageController = TextEditingController();
  DateTime? _dividendDropDate;

  bool get isInvestment => 
    widget.institutionType == 'Mutual Fund' || 
    widget.institutionType == 'Stock' || 
    widget.institutionType == 'Bond' || 
    widget.institutionType == 'Deposit' || 
    widget.institutionType == 'Crypto';

  bool get isVolatile => widget.institutionType == 'Crypto' || widget.institutionType == 'Stock';
  bool get hasDividend => widget.institutionType == 'Stock' || widget.institutionType == 'Mutual Fund' || widget.institutionType == 'Bond';

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.institutionName;
  }

  void _saveWallet() {
    if (_nameController.text.isEmpty || _balanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and balance are required')));
      return;
    }

    final balance = double.tryParse(_balanceController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    double? returnPct;
    if (isInvestment && _returnPercentageController.text.isNotEmpty) {
      returnPct = double.tryParse(_returnPercentageController.text.replaceAll(RegExp(r'[^0-9.]'), ''));
    }

    final newWallet = WalletModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      type: widget.institutionType,
      balance: balance,
      isAutoSync: false,
      returnPercentage: returnPct,
      dividendDropDate: _dividendDropDate,
      isVolatile: isVolatile,
    );

    ref.read(walletsProvider.notifier).addWallet(newWallet);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wallet berhasil ditambahkan')));
    
    // Pop back to home or previous screens
    context.pop();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Input Manual', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nama Wallet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            _buildTextField(controller: _nameController, hint: 'Misal: Tabungan Utama'),
            
            const SizedBox(height: 20),
            const Text('Saldo Saat Ini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            _buildTextField(controller: _balanceController, hint: 'Rp 0', keyboardType: TextInputType.number),
            
            if (isInvestment) ...[
              const SizedBox(height: 20),
              const Text('Return / Bunga (%)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              _buildTextField(controller: _returnPercentageController, hint: 'Misal: 5.0', keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              
              if (hasDividend) ...[
                const SizedBox(height: 20),
                const Text('Tanggal Dividen (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) {
                      setState(() => _dividendDropDate = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _dividendDropDate == null 
                            ? 'Pilih Tanggal Drop Dividen' 
                            : '${_dividendDropDate!.day}/${_dividendDropDate!.month}/${_dividendDropDate!.year}',
                          style: TextStyle(
                            color: _dividendDropDate == null ? Colors.grey.shade500 : Colors.black,
                            fontSize: 14
                          )
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              if (isVolatile) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade800, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Aset ini volatile. Nilainya akan disimulasikan berfluktuasi secara real-time.',
                          style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveWallet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Simpan Wallet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
