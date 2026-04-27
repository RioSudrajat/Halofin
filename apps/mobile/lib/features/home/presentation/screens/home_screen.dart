import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/mock_providers.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _obscureBalance = false;
  int _carouselPage = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = ref.watch(userProvider);
    final transactions = ref.watch(transactionsProvider);
    final wallets = ref.watch(walletsProvider);
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final totalBalance = wallets.fold<double>(0, (sum, w) => sum + w.balance);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // ── Pinned Header ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // HF Logo
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text('HF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('HaloFin', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                        ],
                      ),
                      Row(
                        children: [
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_none, size: 26),
                                onPressed: () {},
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => context.push('/profile'),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary, width: 2),
                              ),
                              child: const CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.grey,
                                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Welcome & Month (compact single row) ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text('Hi, ', style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                          Text(user.name, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const Text(' 👋', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today, size: 12, color: Colors.black54),
                            const SizedBox(width: 4),
                            Text('Maret 2026', style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.black54)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── section_total_balance_hero ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: IntrinsicHeight(
                  child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Portfolio Preview Box
                    GestureDetector(
                      onTap: () => context.push('/reporting'),
                      child: Container(
                        width: 72,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.pie_chart, color: Colors.teal, size: 20),
                            ),
                            const SizedBox(height: 8),
                            const Text('View\nPortfolio', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal)),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Balance Card
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text('TOTAL BALANCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                                      const SizedBox(width: 4),
                                      GestureDetector(
                                        onTap: () => setState(() => _obscureBalance = !_obscureBalance),
                                        child: Icon(_obscureBalance ? Icons.visibility_off : Icons.visibility, size: 14, color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Rp ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                                      Expanded(
                                        child: Text(
                                          _obscureBalance ? '••••••••' : currencyFormat.format(totalBalance).replaceAll('Rp ', ''),
                                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black, height: 1),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Text('Hari ini ', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                                        Icon(Icons.trending_down, size: 10, color: Colors.redAccent),
                                        Text('-Rp 150.000 (-0.5%)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Wallet list inside card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    ...wallets.take(3).map((w) {
                                      IconData wIcon = Icons.account_balance;
                                      if (w.type == 'E-Wallet') wIcon = Icons.account_balance_wallet;
                                      else if (w.type == 'Cash') wIcon = Icons.shopping_bag;
                                      else if (w.type == 'Crypto' || w.type == 'Stock' || w.type == 'Mutual Fund') wIcon = Icons.show_chart;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 6),
                                        child: _buildWalletPill(
                                          w.name.length > 10 ? w.name.substring(0, 10) : w.name,
                                          currencyFormat.format(w.balance),
                                          icon: wIcon,
                                          onTap: () => context.push('/wallet/${w.id}'),
                                        ),
                                      );
                                    }),
                                    // Add wallet button
                                    GestureDetector(
                                      onTap: () => context.push('/wallet/add'),
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                        ),
                                        child: const Icon(Icons.add, size: 16, color: Colors.white70),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                ),
              ),
              const SizedBox(height: 24),

              // ── section_quick_actions ──
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildFeatureAction(Icons.account_balance_wallet, 'Budget', onTap: () => context.go('/budget')),
                    _buildFeatureAction(Icons.history, 'History', onTap: () => context.push('/transaction/history')),
                    _buildFeatureAction(Icons.smart_toy, 'AI Halofin', onTap: () => context.push('/session')),
                    _buildFeatureAction(Icons.credit_score, 'Score'),
                    _buildFeatureAction(Icons.insert_chart, 'Report', onTap: () => context.push('/reporting')),
                    _buildFeatureAction(Icons.receipt_long, 'Bills', onTap: () => context.go('/budget')),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── section_carousel_banners ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SizedBox(
                      height: 120,
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => _carouselPage = i),
                        children: [
                          _buildBannerCard(
                            icon: Icons.star,
                            iconColor: Colors.amber,
                            title: 'Match Expert',
                            subtitle: 'Temukan konsultan yang pas sesuai budget dan masalah finansialmu.',
                            ctaText: 'Coba Sekarang',
                            onTap: () => context.go('/consult'),
                          ),
                          _buildBannerCard(
                            icon: Icons.lightbulb,
                            iconColor: Colors.orange,
                            title: 'Smart Recommendation',
                            subtitle: 'Lihat rekomendasi otomatis berdasarkan pola keuanganmu.',
                            ctaText: 'Lihat',
                          ),
                          _buildBannerCard(
                            icon: Icons.campaign,
                            iconColor: Colors.blue,
                            title: 'Promo Spesial',
                            subtitle: 'Nikmati diskon 50% konsultasi pertama untuk pengguna baru.',
                            ctaText: 'Klaim',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Bar indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _carouselPage == i ? 24 : 12,
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: _carouselPage == i ? AppColors.primary : Colors.grey.shade300,
                        ),
                      )),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── section_monthly_finance ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Keuangan Bulan Ini', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text('Budget', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    Text('75%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: 0.75,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                    minHeight: 8,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: const [
                                    Text('terpakai ', style: TextStyle(fontSize: 10, color: Colors.black54)),
                                    Text('Rp 7.500.000', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                    Text(' / Rp 10.000.000', style: TextStyle(fontSize: 10, color: Colors.black54)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withValues(alpha: 0.3))),
                                  child: const Icon(Icons.smart_toy, color: AppColors.primaryDark, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        _buildAssistantPrompt('Target nabung yang realistis?'),
                                        const SizedBox(width: 8),
                                        _buildAssistantPrompt('Cara naikkan tabungan?'),
                                      ],
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
              const SizedBox(height: 24),

              // ── section_recent_activity ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Activity', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () => context.push('/transaction/history'),
                      child: const Icon(Icons.search, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.take(3).length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  final isExpense = tx.type == 'expense' || tx.type == 'transfer';
                  final amountText = '${isExpense ? "- " : "+ "}${currencyFormat.format(tx.amount)}';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: isExpense ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Icon(isExpense ? Icons.local_taxi : Icons.coffee, size: 16, color: isExpense ? AppColors.error : AppColors.success),
                      ),
                      title: Text(tx.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      subtitle: Text('${tx.category} • ${DateFormat('d MMM').format(tx.date)}', style: const TextStyle(fontSize: 10, color: Colors.black54)),
                      trailing: Text(amountText, style: textTheme.bodyMedium?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 120), // Padding for floating bottom nav
                      ],
                    ),
                  ),
                ),
              ],
            ),
        // Branch Session FAB
        Positioned(
          bottom: 110,
          right: 20,
          child: GestureDetector(
            onTap: () => context.push('/session'),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.support_agent, color: Colors.black, size: 26),
            ),
          ),
        ),
      ]),
      ),
    );
  }

  // ── Helper Widgets ──

  Widget _buildWalletPill(String name, String balance, {IconData? icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(icon ?? Icons.account_balance, size: 12, color: Colors.black),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white70)),
                Text(balance, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureAction(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Icon(icon, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String ctaText,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.black54, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(ctaText, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward, size: 12, color: Colors.black),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssistantPrompt(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
    );
  }
}

