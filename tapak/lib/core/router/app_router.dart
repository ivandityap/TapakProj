import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/map/presentation/map_screen.dart';
import '../../features/map/presentation/place_detail_screen.dart';
import '../../features/explore/presentation/explore_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/favorites_screen.dart';
import '../../features/submission/presentation/suggest_place_screen.dart';
import '../../features/submission/presentation/write_review_screen.dart';
import '../../features/admin/presentation/admin_queue_screen.dart';
import '../../features/admin/presentation/admin_place_review_screen.dart';
import '../../features/admin/presentation/admin_photo_queue_screen.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../providers/auth_providers.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute =
          state.matchedLocation == '/login' || state.matchedLocation == '/signup';

      if (!isLoggedIn && !isAuthRoute) {
        // Allow public routes without login
        final publicRoutes = ['/', '/explore', '/place'];
        final isPublic = publicRoutes.any(
          (r) => state.matchedLocation.startsWith(r),
        );
        if (!isPublic) return '/login';
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const MapScreen(),
          ),
          GoRoute(
            path: '/explore',
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: '/favorites',
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/place/:id',
        builder: (context, state) => PlaceDetailScreen(
          placeId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/place/:id/review',
        builder: (context, state) => WriteReviewScreen(
          placeId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/suggest',
        builder: (context, state) => const SuggestPlaceScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/admin/queue',
        builder: (context, state) => const AdminQueueScreen(),
      ),
      GoRoute(
        path: '/admin/place/:id',
        builder: (context, state) => AdminPlaceReviewScreen(
          placeId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/admin/photos',
        builder: (context, state) => const AdminPhotoQueueScreen(),
      ),
    ],
  );
}
