class TransactionModel {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final String type; // expense, income, transfer
  final String walletId; // Source wallet
  final String? targetWalletId; // Target wallet for transfer
  final String? targetGoalId; // Target goal for transfer

  TransactionModel({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.type,
    required this.walletId,
    this.targetWalletId,
    this.targetGoalId,
  });
}
