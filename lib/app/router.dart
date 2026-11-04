// lib/app/router.dart

import 'package:go_router/go_router.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/role_selection_screen.dart';
import '../features/auth/screens/customer_login_screen.dart';
import '../features/auth/screens/customer_register_screen.dart';
import '../features/auth/screens/worker_login_screen.dart';
import '../features/auth/screens/worker_register_screen.dart';
import '../features/customer/screens/customer_home_screen.dart';
import '../features/customer/screens/customer_profile_screen.dart';
import '../features/worker/screens/worker_home_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/customer/login',
        builder: (context, state) => const CustomerLoginScreen(),
      ),
      GoRoute(
        path: '/customer/register',
        builder: (context, state) => const CustomerRegisterScreen(),
      ),
      GoRoute(
        path: '/worker/login',
        builder: (context, state) => const WorkerLoginScreen(),
      ),
      GoRoute(
        path: '/worker/register',
        builder: (context, state) => const WorkerRegisterScreen(),
      ),
      GoRoute(
        path: '/customer/home',
        builder: (context, state) => const CustomerHomeScreen(),
      ),
      GoRoute(
        path: '/customer/profile',
        builder: (context, state) => const CustomerProfileScreen(),
      ),
      GoRoute(
        path: '/worker/home',
        builder: (context, state) => const WorkerHomeScreen(),
      ),
    ],
  );
}
