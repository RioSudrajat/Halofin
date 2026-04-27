class WalletModel {
  final String id;
  final String name;
  final String type; // Bank, E-Wallet, Cash, Deposit, Mutual Fund, Bond, Stock, Crypto
  final double balance;
  final bool isAutoSync;
  final double? returnPercentage;
  final DateTime? dividendDropDate;
  final bool isVolatile;
  final bool hasClaimedDividend;

  WalletModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    this.isAutoSync = false,
    this.returnPercentage,
    this.dividendDropDate,
    this.isVolatile = false,
    this.hasClaimedDividend = false,
  });

  WalletModel copyWith({
    String? id,
    String? name,
    String? type,
    double? balance,
    bool? isAutoSync,
    double? returnPercentage,
    DateTime? dividendDropDate,
    bool? isVolatile,
    bool? hasClaimedDividend,
  }) {
    return WalletModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      isAutoSync: isAutoSync ?? this.isAutoSync,
      returnPercentage: returnPercentage ?? this.returnPercentage,
      dividendDropDate: dividendDropDate ?? this.dividendDropDate,
      isVolatile: isVolatile ?? this.isVolatile,
      hasClaimedDividend: hasClaimedDividend ?? this.hasClaimedDividend,
    );
  }
}
