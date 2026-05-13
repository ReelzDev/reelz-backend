import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/auth/splash_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/interests_screen.dart';
import '../screens/feed/feed_screen.dart';
import '../screens/feed/comments_screen.dart';
import '../screens/feed/search_screen.dart';
import '../screens/upload/upload_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/points_screen.dart';
import '../screens/profile/vip_screen.dart';
import '../screens/creator/creator_dashboard_screen.dart';
import '../widgets/main_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash',     builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
      GoRoute(path: '/login',      builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
      GoRoute(path: '/interests',  builder: (c, s) => const InterestsScreen()),
      GoRoute(path: '/vip',        builder: (c, s) => const VipScreen()),
      GoRoute(path: '/points',     builder: (c, s) => const PointsScreen()),
      GoRoute(
        path: '/comments/:videoId',
        builder: (c, s) => CommentsScreen(videoId: s.pathParameters['videoId']!),
      ),
      ShellRoute(
        builder: (c, s, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: '/feed',         builder: (c, s) => const FeedScreen()),
          GoRoute(path: '/search',       builder: (c, s) => const SearchScreen()),
          GoRoute(path: '/upload',       builder: (c, s) => const UploadScreen()),
          GoRoute(path: '/creator',      builder: (c, s) => const CreatorDashboardScreen()),
          GoRoute(path: '/profile',      builder: (c, s) => const ProfileScreen()),
          GoRoute(path: '/profile/edit', builder: (c, s) => const EditProfileScreen()),
        ],
      ),
    ],
    errorBuilder: (c, s) => Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: const Center(
        child: Text('صفحة غير موجودة', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
      ),
    ),
  );
});
