import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/wallet_model.dart';
import '../models/transaction_model.dart';
import '../../../features/budget/presentation/providers/finance_providers.dart';

// --- User Provider ---
// User balance will be calculated dynamically in UI from wallets, 
// so totalBalance here is just an initial or dummy value.
final userProvider = Provider<UserModel>((ref) {
  return UserModel(
    id: 'u1',
    name: 'Budi Santoso',
    email: 'budi@example.com',
    totalBalance: 0, 
  );
});

// --- Wallets Provider ---
class WalletsNotifier extends Notifier<List<WalletModel>> {
  Timer? _simulationTimer;
  Timer? _dividendTimer;

  @override
  List<WalletModel> build() {
    _startSimulation();
    _startDividendCheck();
    return [
      WalletModel(id: 'w1', name: 'BCA Utama', type: 'Bank', balance: 12000000, isAutoSync: true),
      WalletModel(id: 'w2', name: 'GoPay', type: 'E-Wallet', balance: 500000, isAutoSync: true),
      WalletModel(id: 'w3', name: 'Investasi Bibit', type: 'Mutual Fund', balance: 10000000, isAutoSync: false, returnPercentage: 5.0),
      WalletModel(id: 'w4', name: 'Dompet Tunai', type: 'Cash', balance: 2000000, isAutoSync: false),
      WalletModel(id: 'w5', name: 'Bitcoin', type: 'Crypto', balance: 5000000, isAutoSync: false, isVolatile: true, returnPercentage: 2.5),
    ];
  }

  void _startSimulation() {
    // Simulate real-time data for volatile assets
    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final random = Random();
      state = state.map((wallet) {
        if (wallet.isVolatile) {
          // Fluctuate return percentage slightly (between -0.5% and +0.5%)
          double change = (random.nextDouble() - 0.5);
          double newReturn = (wallet.returnPercentage ?? 0.0) + change;
          // Calculate new balance based on the slight change
          double newBalance = wallet.balance * (1 + (change / 100));
          return wallet.copyWith(returnPercentage: newReturn, balance: newBalance);
        }
        return wallet;
      }).toList();
    });
  }

  void _startDividendCheck() {
    // Check daily (or frequently) for dividend drops
    _dividendTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      final now = DateTime.now();
      state = state.map((wallet) {
        if (wallet.dividendDropDate != null && !wallet.hasClaimedDividend) {
          // If the drop date is reached or passed
          if (now.isAfter(wallet.dividendDropDate!) || now.isAtSameMomentAs(wallet.dividendDropDate!)) {
            // Accumulate dividend (e.g. 2% of balance)
            double dividendAmount = wallet.balance * ((wallet.returnPercentage ?? 2.0) / 100);
            return wallet.copyWith(
              balance: wallet.balance + dividendAmount,
              hasClaimedDividend: true, // prevent double claim
            );
          }
        }
        return wallet;
      }).toList();
    });
  }

  void addWallet(WalletModel wallet) {
    state = [...state, wallet];
  }

  void updateWallet(WalletModel wallet) {
    state = [
      for (final w in state)
        if (w.id == wallet.id) wallet else w
    ];
  }

  void deleteWallet(String id) {
    state = state.where((w) => w.id != id).toList();
  }

  void updateBalance(String id, double amount, {bool isExpense = false}) {
    state = state.map((wallet) {
      if (wallet.id == id) {
        double newBalance = isExpense ? wallet.balance - amount : wallet.balance + amount;
        return wallet.copyWith(balance: newBalance);
      }
      return wallet;
    }).toList();
  }
}

final walletsProvider = NotifierProvider<WalletsNotifier, List<WalletModel>>(() {
  return WalletsNotifier();
});

// --- Transactions Provider ---
class TransactionsNotifier extends Notifier<List<TransactionModel>> {
  @override
  List<TransactionModel> build() {
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
    ];
  }

  void addTransaction(TransactionModel transaction) {
    state = [transaction, ...state];
    
    // Check for reverse goal transfer: source is 'goal:<goalId>:<walletId>'
    if (transaction.type == 'transfer' && transaction.walletId.startsWith('goal:')) {
      final parts = transaction.walletId.split(':');
      if (parts.length == 3) {
        final goalId = parts[1];
        final sourceWalletId = parts[2];
        // Remove savings from goal
        ref.read(goalsProvider.notifier).removeSavings(goalId, sourceWalletId, transaction.amount);
        // Add back to the target wallet
        if (transaction.targetWalletId != null) {
          ref.read(walletsProvider.notifier).updateBalance(transaction.targetWalletId!, transaction.amount, isExpense: false);
        }
      }
      return;
    }

    // Update wallet balance automatically
    if (transaction.type == 'expense') {
      ref.read(walletsProvider.notifier).updateBalance(transaction.walletId, transaction.amount, isExpense: true);
    } else if (transaction.type == 'income') {
      ref.read(walletsProvider.notifier).updateBalance(transaction.walletId, transaction.amount, isExpense: false);
    } else if (transaction.type == 'transfer') {
      // Deduct from source wallet
      ref.read(walletsProvider.notifier).updateBalance(transaction.walletId, transaction.amount, isExpense: true);
      
      if (transaction.targetGoalId != null) {
        // Transfer to goal — add savings
        ref.read(goalsProvider.notifier).addSavings(
          transaction.targetGoalId!, 
          transaction.walletId, 
          transaction.amount,
        );
      } else if (transaction.targetWalletId != null) {
        // Transfer to another wallet
        ref.read(walletsProvider.notifier).updateBalance(transaction.targetWalletId!, transaction.amount, isExpense: false);
      }
    }
  }

  void deleteTransaction(String id) {
    state = state.where((t) => t.id != id).toList();
  }
}

final transactionsProvider = NotifierProvider<TransactionsNotifier, List<TransactionModel>>(() {
  return TransactionsNotifier();
});
