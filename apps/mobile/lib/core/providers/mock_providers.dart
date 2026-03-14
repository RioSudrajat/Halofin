import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/wallet_model.dart';
import '../models/transaction_model.dart';

// --- User Provider ---
final userProvider = Provider<UserModel>((ref) {
  return UserModel(
    id: 'u1',
    name: 'Budi Santoso',
    email: 'budi@example.com',
    totalBalance: 24500000,
  );
});

// --- Wallets Provider ---
final walletsProvider = Provider<List<WalletModel>>((ref) {
  return [
    WalletModel(id: 'w1', name: 'BCA Utama', type: 'Bank', balance: 12000000, isAutoSync: true),
    WalletModel(id: 'w2', name: 'GoPay', type: 'E-Wallet', balance: 500000, isAutoSync: true),
    WalletModel(id: 'w3', name: 'Investasi Bibit', type: 'Bank', balance: 10000000, isAutoSync: false),
    WalletModel(id: 'w4', name: 'Dompet Tunai', type: 'Cash', balance: 2000000, isAutoSync: false),
  ];
});

// --- Transactions Provider ---
final transactionsProvider = Provider<List<TransactionModel>>((ref) {
  final now = DateTime.now();
  return [
    TransactionModel(
      id: 't1', 
      title: 'Makan Siang', 
      category: 'Makan', 
      amount: 50000, 
      date: now, 
      type: 'expense', 
      walletId: 'w2'
    ),
    TransactionModel(
      id: 't2', 
      title: 'Gaji Bulanan', 
      category: 'Gaji', 
      amount: 15000000, 
      date: now, 
      type: 'income', 
      walletId: 'w1'
    ),
    TransactionModel(
      id: 't3', 
      title: 'Transportasi Kantor', 
      category: 'Transport', 
      amount: 25000, 
      date: now.subtract(const Duration(days: 1)), 
      type: 'expense', 
      walletId: 'w2'
    ),
    TransactionModel(
      id: 't4', 
      title: 'Transfer ke Ibu', 
      category: 'Keluarga', 
      amount: 1000000, 
      date: now.subtract(const Duration(days: 2)), 
      type: 'transfer', 
      walletId: 'w1'
    ),
  ];
});
