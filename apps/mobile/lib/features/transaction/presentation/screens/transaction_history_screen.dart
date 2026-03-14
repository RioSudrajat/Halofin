import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  Widget build(BuildContext context) {
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
              child: IconButton(
                icon: const Icon(Icons.tune, color: Colors.black, size: 20),
                onPressed: () {},
              ),
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
                   // Search Bar
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 16),
                     decoration: BoxDecoration(
                       color: Colors.grey.shade50,
                       borderRadius: BorderRadius.circular(16),
                     ),
                     child: const TextField(
                       decoration: InputDecoration(
                         border: InputBorder.none,
                         hintText: 'Search transactions...',
                         hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                         icon: Icon(Icons.search, color: Colors.grey, size: 20),
                       ),
                     ),
                   ),
                   const SizedBox(height: 16),

                   // Filter Chips
                   SingleChildScrollView(
                     scrollDirection: Axis.horizontal,
                     child: Row(
                       children: [
                         _buildFilterChip('All', isSelected: true, showDropdown: false),
                         _buildFilterChip('Category'),
                         _buildFilterChip('Wallet'),
                         _buildFilterChip('Amount'),
                         _buildFilterChip('Date'),
                       ],
                     ),
                   ),
                   const SizedBox(height: 20),
                   const Divider(height: 1, color: Color(0xFFF3F4F6)),
                   const SizedBox(height: 16),

                   // Summary
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('TOTAL IN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                          SizedBox(height: 2),
                          Text('+Rp 25.500.000', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      Container(width: 1, height: 32, color: Colors.grey.shade200),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text('TOTAL OUT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                          SizedBox(height: 2),
                          Text('-Rp 8.240.000', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                        ],
                      ),
                    ],
                   ),
                 ],
               ),
             ),
             
             // List area
             Padding(
               padding: const EdgeInsets.all(20),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.stretch,
                 children: [
                   _buildDateGroup('Today, Jan 24'),
                   _buildTransactionCard(icon: Icons.lunch_dining, iconBgColor: Colors.orange.shade50, iconColor: Colors.orange.shade600, title: 'McDonald\'s', time: '12:30 PM', category: 'Food & Bev', amount: '-Rp 85.000', isExpense: true),
                   _buildTransactionCard(icon: Icons.local_taxi, iconBgColor: Colors.teal.shade50, iconColor: Colors.teal.shade600, title: 'Gojek Ride', time: '08:15 AM', category: 'Transport', amount: '-Rp 24.000', isExpense: true),
                   _buildTransactionCard(icon: Icons.account_balance_wallet, iconBgColor: Colors.green.shade50, iconColor: Colors.green.shade600, title: 'Top Up E-Wallet', time: '07:45 AM', category: 'Transfer', amount: '-Rp 500.000', isExpense: true),

                   const SizedBox(height: 20),
                   _buildDateGroup('Yesterday, Jan 23'),
                   _buildTransactionCard(icon: Icons.work, iconBgColor: Colors.indigo.shade50, iconColor: Colors.indigo.shade600, title: 'Freelance Project A', time: '04:20 PM', category: 'Income', amount: '+Rp 2.500.000', isExpense: false),
                   _buildTransactionCard(icon: Icons.shopping_cart, iconBgColor: Colors.red.shade50, iconColor: Colors.red.shade600, title: 'Supermarket Weekly', time: '02:10 PM', category: 'Groceries', amount: '-Rp 845.000', isExpense: true),
                   _buildTransactionCard(icon: Icons.subscriptions, iconBgColor: Colors.purple.shade50, iconColor: Colors.purple.shade600, title: 'Netflix Premium', time: '09:00 AM', category: 'Subscription', amount: '-Rp 186.000', isExpense: true),

                   const SizedBox(height: 20),
                   _buildDateGroup('Jan 22'),
                   _buildTransactionCard(icon: Icons.restaurant, iconBgColor: Colors.orange.shade50, iconColor: Colors.orange.shade600, title: 'Dinner with Friends', time: '08:30 PM', category: 'Food', amount: '-Rp 450.000', isExpense: true),
                 ],
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false, bool showDropdown = true}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey.shade600)),
          if (showDropdown) ...[
            const SizedBox(width: 4),
            Icon(Icons.expand_more, size: 16, color: Colors.grey.shade600),
          ]
        ],
      ),
    );
  }

  Widget _buildDateGroup(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
    );
  }

  Widget _buildTransactionCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String time,
    required String category,
    required String amount,
    required bool isExpense,
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
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
              border: Border.all(color: iconBgColor.withValues(alpha: 0.8)),
            ),
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
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle),
                    ),
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
