class WalletModel {
  final String id;
  final String name;
  final String type; // Bank, E-Wallet, Cash
  final double balance;
  final bool isAutoSync;

  WalletModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    this.isAutoSync = false,
  });
}
