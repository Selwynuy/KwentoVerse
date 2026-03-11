import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_state.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/educator_login_page.dart';
import '../../features/auth/presentation/onboarding_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/landing/presentation/landing_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/admin/presentation/admin_shell.dart';
import '../../features/admin/presentation/manage_educators_page.dart';
import '../../features/admin/presentation/school_settings_page.dart';
import '../../features/educator/presentation/educator_shell.dart';
import '../../features/educator/presentation/educator_dashboard_page.dart';
import '../../features/educator/presentation/educator_profile_page.dart';
import '../../features/educator/presentation/story_analytics_page.dart';
import '../../features/educator/presentation/story_management_page.dart';
import '../../features/student/presentation/student_shell.dart';
import '../../features/student/presentation/student_home_page.dart';
import '../../features/student/presentation/story_library_page.dart';
import '../../features/student/presentation/story_details_page.dart';
import '../../features/student/presentation/reader_page.dart';
import '../../features/student/presentation/evaluation_page.dart';
import '../../features/student/presentation/progress_page.dart';
import '../../features/student/presentation/badges_page.dart';
import '../../features/student/presentation/student_profile_page.dart';
import '../../features/student/presentation/avatar_selection_page.dart';
import '../../features/student/presentation/enrollment_page.dart';
import '../../features/student/presentation/student_search_page.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: _GoRouterRefresh(ref),
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final isLoggedIn = auth.isAuthenticated;
      final role = auth.role;
      final path = state.matchedLocation;

      final isProtected = path.startsWith('/student') ||
          path.startsWith('/educator') ||
          path.startsWith('/admin') ||
          path == '/settings';

      // Block protected routes when not logged in.
      if (!isLoggedIn && isProtected) return '/login';

      // When logged in, don't stay on public entry routes.
      if (isLoggedIn &&
          (path == '/' || path == '/login' || path == '/register' || path == '/onboarding')) {
        return _homeFor(role ?? UserRole.student);
      }

      // Guard wrong shell access (minimal; refine later).
      if (isLoggedIn && role != null) {
        if (path.startsWith('/student') && role != UserRole.student) return _homeFor(role);
        if (path.startsWith('/educator') &&
            role != UserRole.educator &&
            role != UserRole.principal) {
          return _homeFor(role);
        }
        if (path.startsWith('/admin') && role != UserRole.admin) return _homeFor(role);
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const LandingPage()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/login-educator', builder: (context, state) => const EducatorLoginPage()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),
      GoRoute(
        path: '/student/avatar-select',
        builder: (context, state) => const AvatarSelectionPage(),
      ),
      GoRoute(
        path: '/student/enroll',
        builder: (context, state) => const EnrollmentPage(),
      ),

      ShellRoute(
        builder: (context, state, child) => StudentShell(child: child),
        routes: [
          GoRoute(path: '/student/home', builder: (context, state) => const StudentHomePage()),
          GoRoute(path: '/student/library', builder: (context, state) => const StoryLibraryPage()),
          GoRoute(path: '/student/search', builder: (context, state) => const StudentSearchPage()),
          GoRoute(
            path: '/student/story/:id',
            builder: (context, state) => StoryDetailsPage(storyId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/student/reader/:id',
            builder: (context, state) => ReaderPage(storyId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/student/evaluation/:storyId/:type',
            builder: (context, state) => EvaluationPage(
              storyId: state.pathParameters['storyId']!,
              type: state.pathParameters['type']!,
            ),
          ),
          GoRoute(path: '/student/progress', builder: (context, state) => const ProgressPage()),
          GoRoute(path: '/student/badges', builder: (context, state) => const BadgesPage()),
          GoRoute(path: '/student/profile', builder: (context, state) => const StudentProfilePage()),
        ],
      ),

      ShellRoute(
        builder: (context, state, child) => EducatorShell(child: child),
        routes: [
          GoRoute(path: '/educator/home', builder: (context, state) => const EducatorDashboardPage()),
          GoRoute(path: '/educator/stories', builder: (context, state) => const StoryManagementPage()),
          GoRoute(
            path: '/educator/stories/new',
            builder: (context, state) => const StoryManagementPage(createMode: true),
          ),
          GoRoute(
            path: '/educator/stories/:id',
            builder: (context, state) => StoryManagementPage(storyId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/educator/analytics/:id',
            builder: (context, state) => StoryAnalyticsPage(storyId: state.pathParameters['id']!),
          ),
          GoRoute(path: '/educator/profile', builder: (context, state) => const EducatorProfilePage()),
        ],
      ),

      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: '/admin/educators', builder: (context, state) => const ManageEducatorsPage()),
          GoRoute(path: '/admin/schools', builder: (context, state) => const SchoolSettingsPage()),
        ],
      ),

      GoRoute(path: '/settings', builder: (context, state) => const SettingsPage()),
    ],
  );
});

String _homeFor(UserRole role) {
  return switch (role) {
    UserRole.student => '/student/home',
    UserRole.educator => '/educator/home',
    UserRole.principal => '/educator/home',
    UserRole.admin => '/admin/educators',
  };
}

class _GoRouterRefresh extends ChangeNotifier {
  _GoRouterRefresh(this.ref) {
    _remove = ref.listen<AuthState>(authControllerProvider, (prev, next) => notifyListeners()).close;
  }

  final Ref ref;
  late final void Function() _remove;

  @override
  void dispose() {
    _remove();
    super.dispose();
  }
}

