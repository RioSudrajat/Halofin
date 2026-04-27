import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/mock_providers.dart';
import '../../../../core/models/transaction_model.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends ConsumerState<TransactionHistoryScreen> {
  final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'makan': case 'makanan & minuman': case 'food & bev': case 'food': return Icons.lunch_dining;
      case 'transport': return Icons.local_taxi;
      case 'belanja': case 'shopping': case 'groceries': return Icons.shopping_cart;
      case 'hiburan': case 'entertainment': return Icons.movie;
      case 'tagihan': case 'subscription': return Icons.subscriptions;
      case 'pendidikan': return Icons.school;
      case 'kesehatan': return Icons.health_and_safety;
      case 'gaji': case 'income': return Icons.work;
      case 'transfer': return Icons.swap_horiz;
      default: return Icons.receipt_long;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'makan': case 'makanan & minuman': case 'food & bev': case 'food': return Colors.orange;
      case 'transport': return Colors.teal;
      case 'belanja': case 'shopping': case 'groceries': return Colors.red;
      case 'hiburan': case 'entertainment': return Colors.purple;
      case 'tagihan': case 'subscription': return Colors.blue;
      case 'gaji': case 'income': return Colors.indigo;
      case 'transfer': return Colors.blue;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);

    double totalIn = 0, totalOut = 0;
    for (final tx in transactions) {
      if (tx.type == 'income') {
        totalIn += tx.amount;
      } else {
        totalOut += tx.amount;
      }
    }

    // Group by date
    final Map<String, List<TransactionModel>> grouped = {};
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    for (final tx in transactions) {
      final txDay = DateTime(tx.date.year, tx.date.month, tx.date.day);
      final todayDay = DateTime(now.year, now.month, now.day);
      String key;
      if (txDay == todayDay) {
        key = 'Hari Ini, ${DateFormat('d MMM').format(tx.date)}';
      } else if (txDay == yesterday) {
        key = 'Kemarin, ${DateFormat('d MMM').format(tx.date)}';
      } else {
        key = DateFormat('d MMM yyyy').format(tx.date);
      }
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transaction History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle),
              child: IconButton(icon: const Icon(Icons.tune, color: Colors.black, size: 20), onPressed: () {}),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Container
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))],
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                children: [
                  // Summary
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TOTAL IN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                          const SizedBox(height: 2),
                          Text('+${formatCurrency.format(totalIn)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      Container(width: 1, height: 32, color: Colors.grey.shade200),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('TOTAL OUT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                          const SizedBox(height: 2),
                          Text('-${formatCurrency.format(totalOut)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Transaction list
            if (transactions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(60),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('Belum ada transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: grouped.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 12),
                          child: Text(entry.key.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                        ),
                        ...entry.value.map((tx) {
                          final isExpense = tx.type == 'expense' || tx.type == 'transfer';
                          final color = _getCategoryColor(tx.category);
                          return _buildTransactionCard(
                            icon: _getCategoryIcon(tx.category),
                            iconBgColor: color.withValues(alpha: 0.1),
                            iconColor: color,
                            title: tx.title,
                            time: DateFormat('HH:mm').format(tx.date),
                            category: tx.category,
                            amount: '${isExpense ? "-" : "+"}${formatCurrency.format(tx.amount)}',
                            isExpense: isExpense,
                          );
                        }),
                        const SizedBox(height: 20),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard({
    required IconData icon, required Color iconBgColor, required Color iconColor,
    required String title, required String time, required String category,
    required String amount, required bool isExpense,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            height: 48, width: 48,
            decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(time, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey.shade500)),
                    Container(margin: const EdgeInsets.symmetric(horizontal: 6), width: 4, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle)),
                    Text(category, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey.shade500)),
                  ],
                ),
              ],
            ),
          ),
          Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isExpense ? Colors.red.shade500 : Colors.green.shade600)),
        ],
      ),
    );
  }
}
