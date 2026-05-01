import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../shared/widgets/placeholder_screen.dart';
import '../shared/widgets/app_bottom_nav.dart';
import '../features/auth/presentation/screens/auth_login_screen.dart';
import '../features/auth/presentation/screens/auth_register_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_welcome_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_wallet_setup_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_set_goal_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/wallet/presentation/screens/wallet_screen.dart';
import '../features/wallet/presentation/screens/wallet_detail_screen.dart';
import '../features/wallet/presentation/screens/add_wallet_institution_screen.dart';
import '../features/budget/presentation/screens/budget_screen.dart';
import '../features/consult/presentation/screens/consult_list_screen.dart';
import '../features/consult/presentation/screens/consult_detail_screen.dart';
import '../features/consult/presentation/screens/booking_service_screen.dart';
import '../features/consult/presentation/screens/booking_time_screen.dart';
import '../features/goals/presentation/screens/add_edit_goal_screen.dart';
import '../features/goals/presentation/screens/goal_detail_screen.dart';
import '../features/budget/presentation/screens/add_edit_budget_screen.dart';
import '../features/bills/presentation/screens/add_edit_bill_screen.dart';
import '../features/consult/presentation/screens/booking_pre_consultation_screen.dart';
import '../features/consult/presentation/screens/booking_payment_screen.dart';
import '../features/transaction/presentation/screens/transaction_entry_screen.dart';
import '../features/transaction/presentation/screens/transaction_history_screen.dart';
import '../features/transaction/presentation/screens/ai_draft_review_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/report/presentation/screens/report_dashboard_screen.dart';
import '../features/session/presentation/screens/branch_session_screen.dart';
import '../features/transaction/presentation/screens/transaction_success_screen.dart';

// Keys for each navigator branch
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _budgetNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'budget');
final _consultNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'consult');
final _walletNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'wallet');

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      // --- Auth & Onboarding (outside shell) ---
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AuthLoginScreen(),
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AuthRegisterScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingWelcomeScreen(),
        routes: [
          GoRoute(
            path: 'wallet-setup',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const OnboardingWalletSetupScreen(),
          ),
          GoRoute(
            path: 'goal',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const OnboardingSetGoalScreen(),
          ),
        ],
      ),

      // --- Main App Shell with Bottom Nav (4 branches) ---
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Branch 1: Budget (internal tabs for Goals/Budget/Bills)
          StatefulShellBranch(
            navigatorKey: _budgetNavigatorKey,
            routes: [
              GoRoute(
                path: '/budget',
                builder: (context, state) => const BudgetScreen(),
              ),
            ],
          ),
          // Branch 2: Consult
          StatefulShellBranch(
            navigatorKey: _consultNavigatorKey,
            routes: [
              GoRoute(
                path: '/consult',
                builder: (context, state) => const ConsultListScreen(),
              ),
            ],
          ),
          // Branch 3: Wallet
          StatefulShellBranch(
            navigatorKey: _walletNavigatorKey,
            routes: [
              GoRoute(
                path: '/wallet',
                builder: (context, state) => const WalletScreen(),
              ),
            ],
          ),
        ],
      ),

      // --- Routes shown ABOVE the shell (full-screen, no bottom nav) ---
      GoRoute(
        path: '/goal/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddEditGoalScreen(),
      ),
      GoRoute(
        path: '/goal/edit/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => AddEditGoalScreen(goalId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/goal/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => GoalDetailScreen(goalId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/budget/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddEditBudgetScreen(),
      ),
      GoRoute(
        path: '/budget/edit/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => AddEditBudgetScreen(budgetId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/bill/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddEditBillScreen(),
      ),
      GoRoute(
        path: '/bill/edit/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => AddEditBillScreen(billId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/consult/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ConsultDetailScreen(consultantId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/wallet/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddWalletInstitutionScreen(),
      ),
      GoRoute(
        path: '/wallet/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => WalletDetailScreen(walletId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/booking/:consultantId/service',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => BookingServiceScreen(consultantId: state.pathParameters['consultantId']!),
      ),
      GoRoute(
        path: '/booking/:consultantId/time',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => BookingTimeScreen(consultantId: state.pathParameters['consultantId']!),
      ),
      GoRoute(
        path: '/booking/:consultantId/pre-consult',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => BookingPreConsultationScreen(consultantId: state.pathParameters['consultantId']!),
      ),
      GoRoute(
        path: '/booking/:consultantId/payment',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => BookingPaymentScreen(consultantId: state.pathParameters['consultantId']!),
      ),
      GoRoute(
        path: '/transaction/entry',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return TransactionEntryScreen(
            prefilledType: extra?['type'] as String?,
            prefilledTargetGoalId: extra?['targetGoalId'] as String?,
            prefilledSourceWalletId: extra?['sourceWalletId'] as String?,
            prefilledTargetWalletId: extra?['targetWalletId'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/transaction/success',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return TransactionSuccessScreen(returnTo: extra?['returnTo'] as String?);
        },
      ),
      GoRoute(
        path: '/transaction/history',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TransactionHistoryScreen(),
      ),
      GoRoute(
        path: '/draft/review',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AiDraftReviewScreen(),
      ),
      GoRoute(
        path: '/reporting',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ReportDashboardScreen(),
      ),
      GoRoute(
        path: '/export',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PlaceholderScreen(title: 'Data Export'),
      ),
      GoRoute(
        path: '/session',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BranchSessionScreen(),
      ),
      GoRoute(
        path: '/profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
