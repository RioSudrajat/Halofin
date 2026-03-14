import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class AddWalletInstitutionScreen extends StatefulWidget {
  const AddWalletInstitutionScreen({super.key});

  @override
  State<AddWalletInstitutionScreen> createState() => _AddWalletInstitutionScreenState();
}

class _AddWalletInstitutionScreenState extends State<AddWalletInstitutionScreen> {
  String _searchQuery = '';

  final _banks = [
    _Institution('BCA', Icons.account_balance, true),
    _Institution('Mandiri', Icons.account_balance, true),
    _Institution('BRI', Icons.account_balance, true),
    _Institution('Bank Syariah Indonesia', Icons.account_balance, false),
    _Institution('BNI', Icons.account_balance, true),
  ];

  final _ewallets = [
    _Institution('GoPay', Icons.account_balance_wallet, true),
    _Institution('OVO', Icons.account_balance_wallet, true),
    _Institution('DANA', Icons.account_balance_wallet, true),
    _Institution('ShopeePay', Icons.account_balance_wallet, false),
  ];

  final _investments = [
    _Institution('Stockbit', Icons.show_chart, false),
    _Institution('Pintu Crypto', Icons.currency_bitcoin, false),
    _Institution('Emas Fisik/Digital', Icons.diamond, false),
    _Institution('Cash / Dompet Tunai', Icons.wallet, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Tambah Wallet Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Cari bank, e-wallet, atau aset...',
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // Sections
            _buildSection('Bank Populer', _banks),
            _buildSection('E-Wallet', _ewallets),
            _buildSection('Investasi & Aset Lainnya', _investments),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<_Institution> items) {
    final filtered = _searchQuery.isEmpty
        ? items
        : items.where((i) => i.name.toLowerCase().contains(_searchQuery)).toList();
    if (filtered.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey.shade500, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: List.generate(filtered.length, (i) {
                final inst = filtered[i];
                return Column(
                  children: [
                    if (i > 0) Divider(height: 1, color: Colors.grey.shade100, indent: 60),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(inst.icon, size: 20, color: Colors.grey.shade700),
                      ),
                      title: Text(inst.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (inst.supportsAutoSync)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('⚡ Auto', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                            ),
                          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
                        ],
                      ),
                      onTap: () {
                        if (inst.supportsAutoSync) {
                          _showSyncChoiceBottomSheet(context, inst.name);
                        } else {
                          // Navigate directly to manual input (future screen)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${inst.name} ditambahkan secara manual')),
                          );
                          context.pop();
                        }
                      },
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showSyncChoiceBottomSheet(BuildContext context, String institutionName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Text('Pilih Metode Sinkronisasi', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Kamu mau input data $institutionName kamu secara otomatis atau manual?', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 20),

            // Auto option
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Menghubungkan $institutionName otomatis...')));
                context.pop();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.flash_on, color: Colors.black, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Hubungkan Otomatis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text('Transaksi akan ditarik otomatis dari bank. Aman & terenkripsi.', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                      child: const Text('Rekomendasi', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Manual option
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$institutionName ditambahkan secara manual')));
                context.pop();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.edit_note, color: Colors.grey.shade600, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Input Manual', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text('Kamu yang masukin saldo dan transaksi satu per satu.', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Cancel
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Batal', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Institution {
  final String name;
  final IconData icon;
  final bool supportsAutoSync;
  const _Institution(this.name, this.icon, this.supportsAutoSync);
}
