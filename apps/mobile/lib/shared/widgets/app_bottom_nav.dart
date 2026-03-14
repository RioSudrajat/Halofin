import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(navigationShell: navigationShell),
    );
  }
}

class AppBottomNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  
  const AppBottomNav({super.key, required this.navigationShell});

  void _onTap(BuildContext context, int index) {
    // FAB is center index (2)
    if (index == 2) {
      context.push('/transaction/entry');
      return;
    }
    
    // Convert 5-item index to 4-branch index
    int branchIndex = index > 2 ? index - 1 : index;
    
    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.navBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.border.withValues(alpha: 0.5),
            offset: const Offset(0, 0),
            blurRadius: 1,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(context, 0, Icons.home_filled, Icons.home_outlined, 'Home'),
              _buildNavItem(context, 1, Icons.account_balance_wallet, Icons.account_balance_wallet_outlined, 'Budget'),
              const SizedBox(width: 56), // Space for FAB
              _buildNavItem(context, 3, Icons.chat_bubble, Icons.chat_bubble_outline, 'Consult'),
              _buildNavItem(context, 4, Icons.work, Icons.work_outline, 'Wallet'),
            ],
          ),
          Positioned(
            top: -24,
            child: GestureDetector(
              onTap: () => _onTap(context, 2),
              child: Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.black, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData activeIcon, IconData icon, String label) {
    // Current branch index maps to 0, 1, 3, 4
    final branchIndex = index > 2 ? index - 1 : index;
    final isActive = (index != 2) && (navigationShell.currentIndex == branchIndex);
    final color = isActive ? AppColors.primaryDark : AppColors.textSecondary;
    
    return GestureDetector(
      onTap: () => _onTap(context, index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
