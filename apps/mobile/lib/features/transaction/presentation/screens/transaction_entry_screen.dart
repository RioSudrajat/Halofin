import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/transaction_model.dart';
import '../../../../core/models/wallet_model.dart';
import '../../../../core/providers/mock_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../budget/presentation/providers/finance_providers.dart';

class TransactionEntryScreen extends ConsumerStatefulWidget {
  final String? prefilledType;
  final String? prefilledTargetGoalId;
  final String? prefilledSourceWalletId;
  final String? prefilledTargetWalletId;

  const TransactionEntryScreen({
    super.key,
    this.prefilledType,
    this.prefilledTargetGoalId,
    this.prefilledSourceWalletId,
    this.prefilledTargetWalletId,
  });

  @override
  ConsumerState<TransactionEntryScreen> createState() =>
      _TransactionEntryScreenState();
}

class _TransactionEntryScreenState extends ConsumerState<TransactionEntryScreen>
    with TickerProviderStateMixin {
  String _type = 'Pengeluaran';
  DateTime _selectedDate = DateTime.now();
  String _dateString = 'Hari Ini';
  String? _selectedWalletId;
  String? _targetWalletId;
  String? _targetGoalId;
  String? _successReturnTo;
  String _category = 'Makanan & minuman';
  bool _showInlineSuccess = false;

  final _amountController = TextEditingController(text: '');
  final _amountFocusNode = FocusNode();
  final _notesController = TextEditingController();
  final _notesFocusNode = FocusNode();
  final _sheetScrollController = ScrollController();
  final _notesFieldKey = GlobalKey();

  double _sheetProgress = 0;
  late AnimationController _snapBackController;
  late Animation<double> _sheetProgressAnimation;
  late AnimationController _cursorBlinkController;

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
  void initState() {
    super.initState();
    _cursorBlinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);

    _snapBackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _sheetProgressAnimation =
        Tween<double>(begin: 0, end: 0).animate(
          CurvedAnimation(parent: _snapBackController, curve: Curves.easeOut),
        )..addListener(() {
          if (mounted) {
            setState(() => _sheetProgress = _sheetProgressAnimation.value);
          }
        });

    _amountFocusNode.addListener(() {
      if (mounted) setState(() {});
    });

    _notesFocusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (_notesFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 260), _scrollSheetToNotes);
      }
    });

    if (widget.prefilledType != null) {
      _type = widget.prefilledType!;
    }
    if (widget.prefilledTargetGoalId != null) {
      _targetGoalId = widget.prefilledTargetGoalId;
    }
    if (widget.prefilledSourceWalletId != null) {
      _selectedWalletId = widget.prefilledSourceWalletId;
    }
    if (widget.prefilledTargetWalletId != null) {
      _targetWalletId = widget.prefilledTargetWalletId;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    _notesController.dispose();
    _notesFocusNode.dispose();
    _sheetScrollController.dispose();
    _snapBackController.dispose();
    _cursorBlinkController.dispose();
    super.dispose();
  }

  String get _displayAmount {
    final text = _amountController.text.replaceAll('.', '');
    if (text.isEmpty) {
      return _amountFocusNode.hasFocus ? '' : '0';
    }
    return _formatAmount(text);
  }

  List<WalletModel> _getFilteredWallets(List<WalletModel> wallets) {
    if (_type == 'Pengeluaran') {
      return wallets.where((w) {
        return w.type == 'Bank' || w.type == 'E-Wallet' || w.type == 'Cash';
      }).toList();
    }
    return wallets;
  }

  bool _saveTransaction() {
    final amt =
        double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;
    if (amt <= 0 || _selectedWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal dan dompet harus diisi')),
      );
      return false;
    }

    if (_type == 'Transfer' &&
        _targetWalletId == null &&
        _targetGoalId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih tujuan transfer')));
      return false;
    }

    if (_type == 'Transfer' && _targetGoalId != null) {
      final wallet = ref
          .read(walletsProvider)
          .firstWhere((w) => w.id == _selectedWalletId);
      if (wallet.isVolatile && amt != wallet.balance) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aset volatile harus ditransfer seluruhnya ke goals'),
          ),
        );
        return false;
      }
    }

    final type = _type == 'Pemasukan'
        ? 'income'
        : (_type == 'Pengeluaran' ? 'expense' : 'transfer');
    final notes = _notesController.text.trim();
    final tx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      walletId: _selectedWalletId!,
      type: type,
      amount: amt,
      category: _type == 'Transfer' ? 'Transfer' : _category,
      date: _selectedDate,
      title: notes.isNotEmpty
          ? notes
          : (_type == 'Transfer' ? 'Transfer' : _category),
      targetWalletId: _targetWalletId,
      targetGoalId: _targetGoalId,
    );

    ref.read(transactionsProvider.notifier).addTransaction(tx);

    String? goalIdForReturn = _targetGoalId;
    if (goalIdForReturn == null &&
        _selectedWalletId != null &&
        _selectedWalletId!.startsWith('goal:')) {
      final parts = _selectedWalletId!.split(':');
      if (parts.length >= 2) goalIdForReturn = parts[1];
    }

    _successReturnTo = goalIdForReturn != null
        ? '/goal/$goalIdForReturn'
        : null;
    return true;
  }

  void _scrollSheetToNotes() {
    if (!_sheetScrollController.hasClients || !mounted) return;
    _sheetScrollController.animateTo(
      _sheetScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );

    final notesContext = _notesFieldKey.currentContext;
    if (notesContext != null) {
      Scrollable.ensureVisible(
        notesContext,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: 0.72,
      );
    }
  }

  Future<void> _snapSheetToProgress(
    double progress, {
    Curve curve = Curves.easeOutCubic,
  }) {
    _sheetProgressAnimation = Tween<double>(
      begin: _sheetProgress,
      end: progress,
    ).animate(CurvedAnimation(parent: _snapBackController, curve: curve));
    return _snapBackController.forward(from: 0);
  }

  void _finishSwipe() {
    FocusScope.of(context).unfocus();
    if (!_saveTransaction()) {
      _snapSheetToProgress(0, curve: Curves.elasticOut);
      return;
    }

    _snapSheetToProgress(1).whenComplete(() {
      if (!mounted) return;
      setState(() {
        _sheetProgress = 1;
        _showInlineSuccess = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsProvider);
    final goals = ref.watch(goalsProvider);
    final filteredWallets = _getFilteredWallets(wallets);
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final notesKeyboardLift = _notesFocusNode.hasFocus
        ? math.min(MediaQuery.viewInsetsOf(context).bottom, 320.0)
        : 0.0;

    if (_selectedWalletId == null && filteredWallets.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _selectedWalletId = filteredWallets.first.id);
        }
      });
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: notesKeyboardLift),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final collapsedSheetHeight = math.min(
                _type == 'Transfer' ? 440.0 : 360.0,
                constraints.maxHeight * 0.58,
              );
              final expandedSheetHeight = constraints.maxHeight;
              final sheetHeight =
                  collapsedSheetHeight +
                  ((expandedSheetHeight - collapsedSheetHeight) *
                      _sheetProgress);

              return Stack(
                children: [
                  Positioned.fill(
                    child: _buildEntryBackdrop(
                      bottomInset: keyboardVisible
                          ? math.max(collapsedSheetHeight - 12 - notesKeyboardLift, 0.0)
                          : collapsedSheetHeight - 12,
                      wallets: wallets,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: sheetHeight,
                    child: _buildBottomSheet(
                      wallets: wallets,
                      goals: goals,
                      filteredWallets: filteredWallets,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEntryBackdrop({
    required double bottomInset,
    required List<WalletModel> wallets,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ClipRect(
        child: Column(
          children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(Icons.close, color: Colors.black, size: 28),
                ),
                const Text(
                  'Catat Transaksi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Upload',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                PopupMenuButton<String>(
                  onSelected: (val) => setState(() {
                    _type = val;
                    _targetWalletId = null;
                    _targetGoalId = null;
                    final filtered = _getFilteredWallets(wallets);
                    if (_selectedWalletId != null &&
                        !filtered.any((w) => w.id == _selectedWalletId)) {
                      _selectedWalletId = filtered.isNotEmpty
                          ? filtered.first.id
                          : null;
                    }
                  }),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  offset: const Offset(0, 48),
                  itemBuilder: (_) => [
                    _buildTypeMenuItem(
                      'Pengeluaran',
                      Icons.arrow_upward,
                      Colors.red.shade400,
                    ),
                    _buildTypeMenuItem(
                      'Pemasukan',
                      Icons.arrow_downward,
                      Colors.green.shade400,
                    ),
                    _buildTypeMenuItem(
                      'Transfer',
                      Icons.swap_horiz,
                      Colors.blue.shade400,
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _type == 'Pengeluaran'
                                ? Colors.red.shade400
                                : (_type == 'Transfer'
                                      ? Colors.blue.shade400
                                      : Colors.green.shade400),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _type == 'Pengeluaran'
                                ? Icons.arrow_upward
                                : (_type == 'Transfer'
                                      ? Icons.swap_horiz
                                      : Icons.arrow_downward),
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _type,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.expand_more,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showDatePicker(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _dateString,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.expand_more,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
                        const Flexible(
                          child: Text(
                            'Coba catat pakai AI, lebih praktis!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.flash_on,
                          color: Colors.yellow.shade600,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Coba',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            child: GestureDetector(
              onTap: () => _amountFocusNode.requestFocus(),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Rp',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 280,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: 0,
                            child: TextField(
                              controller: _amountController,
                              focusNode: _amountFocusNode,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (_displayAmount.isNotEmpty)
                                  Text(
                                    _displayAmount,
                                    style: const TextStyle(
                                      fontSize: 56,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                if (_amountFocusNode.hasFocus)
                                  FadeTransition(
                                    opacity: _cursorBlinkController,
                                    child: Container(
                                      width: 3,
                                      height: 48,
                                      margin: const EdgeInsets.only(left: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
                  Flexible(
                    child: Text(
                      'Duplikat data transaksi yang lalu',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 16, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet({
    required List<WalletModel> wallets,
    required List<GoalModel> goals,
    required List<WalletModel> filteredWallets,
  }) {
    final radius = BorderRadius.vertical(
      top: Radius.circular(_showInlineSuccess ? 0 : 28 * (1 - _sheetProgress)),
    );

    return GestureDetector(
      onVerticalDragUpdate: _showInlineSuccess
          ? null
          : (details) {
              setState(() {
                _sheetProgress = (_sheetProgress - (details.delta.dy / 360))
                    .clamp(0.0, 1.0);
              });
            },
      onVerticalDragEnd: _showInlineSuccess
          ? null
          : (details) {
              if (_sheetProgress > 0.35 ||
                  (details.primaryVelocity != null &&
                      details.primaryVelocity! < -300)) {
                _finishSwipe();
              } else {
                _snapSheetToProgress(0, curve: Curves.elasticOut);
              }
            },
      child: Material(
        color: Colors.white,
        elevation: 16,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: _showInlineSuccess
            ? _buildInlineSuccess()
            : _buildFormSheetContent(
                wallets: wallets,
                goals: goals,
                filteredWallets: filteredWallets,
              ),
      ),
    );
  }

  Widget _buildFormSheetContent({
    required List<WalletModel> wallets,
    required List<GoalModel> goals,
    required List<WalletModel> filteredWallets,
  }) {
    return SingleChildScrollView(
      controller: _sheetScrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_type == 'Transfer') _buildSectionLabel('SUMBER DARI'),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filteredWallets.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final wallet = filteredWallets[index];
                return _buildWalletChip(
                  wallet: wallet,
                  selected: _selectedWalletId == wallet.id,
                  onTap: () => setState(() => _selectedWalletId = wallet.id),
                );
              },
            ),
          ),
          if (_type == 'Transfer') ...[
            const SizedBox(height: 12),
            _buildSectionLabel('TRANSFER KE'),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...wallets.where((w) => w.id != _selectedWalletId).map((
                    wallet,
                  ) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildWalletChip(
                        wallet: wallet,
                        selected:
                            _targetWalletId == wallet.id &&
                            _targetGoalId == null,
                        onTap: () => setState(() {
                          _targetWalletId = wallet.id;
                          _targetGoalId = null;
                        }),
                      ),
                    );
                  }),
                  ...goals.map((goal) {
                    final selected = _targetGoalId == goal.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _targetGoalId = goal.id;
                          _targetWalletId = null;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.indigo
                                : Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? Colors.indigo
                                  : Colors.indigo.shade100,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.flag,
                                size: 16,
                                color: selected
                                    ? Colors.white
                                    : Colors.indigo.shade400,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                goal.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? Colors.white
                                      : Colors.indigo.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (_type != 'Transfer') ...[
            GestureDetector(
              onTap: () => _showCategoryPicker(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        size: 18,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _category,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(Icons.expand_more, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            key: _notesFieldKey,
            controller: _notesController,
            focusNode: _notesFocusNode,
            minLines: 3,
            maxLines: 5,
            textInputAction: TextInputAction.newline,
            cursorColor: AppColors.primaryDark,
            cursorWidth: 2.5,
            cursorRadius: const Radius.circular(2),
            onTap: _scrollSheetToNotes,
            decoration: InputDecoration(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notes, size: 15, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  const Text('Catatan'),
                ],
              ),
              hintText: 'Tambahkan catatan di sini...',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              filled: true,
              fillColor: _notesFocusNode.hasFocus
                  ? AppColors.primaryDark.withValues(alpha: 0.04)
                  : Colors.grey.shade50,
              alignLabelWithHint: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade100),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.primaryDark,
                  width: 1.4,
                ),
              ),
            ),
            style: const TextStyle(fontSize: 14, height: 1.35),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              const Icon(Icons.keyboard_arrow_up, size: 20, color: Colors.grey),
              Text(
                'SWIPE UP TO FINISH',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade400,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInlineSuccess() {
    final hasReturnTo =
        _successReturnTo != null && _successReturnTo!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Spacer(),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 650),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 46),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Transaksi Berhasil!',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Transaksi Anda telah dicatat\ndengan aman.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.35,
              color: Colors.grey.shade600,
            ),
          ),
          const Spacer(),
          if (hasReturnTo) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go(_successReturnTo!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Kembali ke Goal',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasReturnTo
                    ? Colors.grey.shade100
                    : AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                hasReturnTo ? 'Ke Beranda' : 'Selesai',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildWalletChip({
    required WalletModel wallet,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              _getWalletIcon(wallet),
              size: 16,
              color: selected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              wallet.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildTypeMenuItem(
    String label,
    IconData icon,
    Color color,
  ) {
    return PopupMenuItem(
      value: label,
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  IconData _getWalletIcon(WalletModel wallet) {
    final wType = wallet.type.toLowerCase();
    if (wType == 'bank') return Icons.account_balance;
    if (wType == 'e-wallet') return Icons.account_balance_wallet;
    if (wType == 'cash') return Icons.attach_money;
    if (wType == 'stock' || wType == 'crypto' || wType == 'mutual fund') {
      return Icons.show_chart;
    }
    return Icons.account_balance_wallet;
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      setState(() {
        _selectedDate = picked;
        _dateString =
            (picked.day == now.day &&
                picked.month == now.month &&
                picked.year == now.year)
            ? 'Hari Ini'
            : '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _categories.map((cat) {
            return ListTile(
              title: Text(cat),
              trailing: _category == cat
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() => _category = cat);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
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
