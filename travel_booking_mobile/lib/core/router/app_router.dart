import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/auth/auth_state.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/booking/booking_confirmation_screen.dart';
import '../../presentation/screens/booking/booking_screen.dart';
import '../../presentation/screens/booking_history/booking_history_screen.dart';
import '../../presentation/screens/favorites/favorites_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/plan_detail/plan_detail_screen.dart';
import '../../presentation/screens/recently_viewed/recently_viewed_screen.dart';

part 'app_router.g.dart';

// 認証が必要なルートかどうかを判定する
bool _requiresAuth(String path) {
  return path == '/booking-history' ||
      RegExp(r'^/plan/[^/]+/booking$').hasMatch(path);
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final loginNotifier = ValueNotifier<bool>(
    ref.read(authStateProvider).isLoggedIn,
  );

  ref.listen<AuthState>(authStateProvider, (_, next) {
    loginNotifier.value = next.isLoggedIn;
  });

  ref.onDispose(loginNotifier.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: loginNotifier,
    redirect: (context, routerState) {
      final isLoggedIn = loginNotifier.value;
      final path = routerState.uri.path;
      final isAuthPage = path == '/login' || path == '/register';

      // 未ログイン → 認証必須ルート: /login?from=<元のパス> へリダイレクト
      if (!isLoggedIn && _requiresAuth(path)) {
        return Uri(
          path: '/login',
          queryParameters: {'from': routerState.uri.toString()},
        ).toString();
      }

      // ログイン済み → 認証ページ: from パラメータがあればそこへ、なければ /
      if (isLoggedIn && isAuthPage) {
        final from = routerState.uri.queryParameters['from'];
        return (from != null && from.isNotEmpty) ? from : '/';
      }

      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _ScaffoldWithBottomNav(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'plan/:id',
                    name: 'plan-detail',
                    builder: (context, state) {
                      final planId = state.pathParameters['id']!;
                      return PlanDetailScreen(planId: planId);
                    },
                    routes: [
                      GoRoute(
                        path: 'booking',
                        name: 'booking',
                        builder: (context, state) {
                          final planId = state.pathParameters['id']!;
                          return BookingScreen(planId: planId);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                name: 'favorites',
                builder: (context, state) => const FavoritesScreen(),
                routes: [
                  GoRoute(
                    path: 'plan/:id',
                    name: 'favorites-plan-detail',
                    builder: (context, state) {
                      final planId = state.pathParameters['id']!;
                      return PlanDetailScreen(planId: planId);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/booking-history',
                name: 'booking-history',
                builder: (context, state) => const BookingHistoryScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/recently-viewed',
        name: 'recently-viewed',
        builder: (context, state) => const RecentlyViewedScreen(),
        routes: [
          GoRoute(
            path: 'plan/:id',
            name: 'recently-viewed-plan-detail',
            builder: (context, state) {
              final planId = state.pathParameters['id']!;
              return PlanDetailScreen(planId: planId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/booking/confirmation/:bookingId',
        name: 'booking-confirmation',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          final extra = state.extra as Map<String, dynamic>?;
          return BookingConfirmationScreen(
            bookingId: bookingId,
            planTitle: extra?['planTitle'] as String? ?? '',
            totalPrice: extra?['totalPrice'] as double? ?? 0,
            travelDate: extra?['travelDate'] as DateTime?,
            numberOfPeople: extra?['numberOfPeople'] as int? ?? 1,
          );
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
    ],
  );
}

class _ScaffoldWithBottomNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _ScaffoldWithBottomNav({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'プラン',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'お気に入り',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: '予約履歴',
          ),
        ],
      ),
    );
  }
}
