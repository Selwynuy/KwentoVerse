import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_state.dart';
import '../../features/auth/presentation/student_login_page.dart';
import '../../features/auth/presentation/educator_login_page.dart';
import '../../features/auth/presentation/onboarding_page.dart';
import '../../features/auth/presentation/student_register_page.dart';
import '../../features/auth/presentation/educator_register_page.dart';
import '../../features/landing/presentation/landing_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/admin/presentation/admin_shell.dart';
import '../../features/admin/presentation/manage_educators_page.dart';
import '../../features/admin/presentation/school_settings_page.dart';
import '../../features/educator/presentation/educator_shell.dart';
import '../../features/educator/presentation/educator_home_page.dart';
import '../../features/educator/presentation/educator_library_page.dart';
import '../../features/educator/presentation/educator_search_page.dart';
import '../../features/educator/presentation/school_settings_page.dart'
    as educator_school;
import '../../features/educator/presentation/story_readers_page.dart';
import '../../features/educator/presentation/student_progress_view.dart';
import '../../features/educator/presentation/educator_profile_page.dart';
import '../../features/educator/presentation/questionnaire_creation_page.dart';
import '../../features/educator/presentation/story_management_page.dart';
import '../../features/principal/presentation/principal_educators_page.dart';
import '../../features/principal/presentation/principal_enrolled_students_page.dart';
import '../../features/principal/presentation/principal_story_books_page.dart';
import '../../features/student/data/student_profile_providers.dart';
import '../../features/student/data/student_profile_repository.dart';
import '../../features/student/presentation/student_shell.dart';
import '../../features/student/presentation/student_home_page.dart';
import '../../features/student/presentation/story_library_page.dart';
import '../../features/student/presentation/story_details_page.dart';
import '../../features/student/presentation/reader_page.dart';
import '../../features/student/presentation/evaluation_page.dart';
import '../../features/student/presentation/progress_page.dart';
import '../../features/student/presentation/student_profile_page.dart';
import '../../features/student/presentation/avatar_selection_page.dart';
import '../../features/student/presentation/enrollment_page.dart';
import '../../features/student/presentation/student_search_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _studentShellNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: _GoRouterRefresh(ref),
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final isLoggedIn = auth.isAuthenticated;
      final role = auth.role;
      final path = state.matchedLocation;

      final isProtected = path.startsWith('/student') ||
          path.startsWith('/educator') ||
          path.startsWith('/principal') ||
          path.startsWith('/admin') ||
          path == '/settings';

      // Block protected routes when not logged in.
      if (!isLoggedIn && isProtected) return '/login';

      // When logged in, don't stay on public entry routes.
      if (isLoggedIn &&
          (path == '/' ||
              path == '/login' ||
              path == '/login-educator' ||
              path == '/register' ||
              path == '/register-educator' ||
              path == '/onboarding')) {
        return _homeFor(role ?? UserRole.student);
      }

      // Students without an avatar must pick one first.
      if (isLoggedIn && role == UserRole.student) {
        final profileAsync = ref.read(myStudentProfileProvider);
        final avatarIndex = profileAsync.value?.avatarIndex;
        final hasAvatar = avatarIndex != null;
        if (!hasAvatar && path != '/student/avatar-select') {
          return '/student/avatar-select';
        }
        if (hasAvatar && path == '/student/avatar-select') {
          return '/student/home';
        }
      }

      // Guard wrong shell access (minimal; refine later).
      if (isLoggedIn && role != null) {
        if (path.startsWith('/student') && role != UserRole.student) return _homeFor(role);
        if (path.startsWith('/educator') &&
            role != UserRole.educator &&
            role != UserRole.principal) {
          return _homeFor(role);
        }
        if (path.startsWith('/principal') && role != UserRole.principal) return _homeFor(role);
        if (path.startsWith('/admin') && role != UserRole.admin) return _homeFor(role);
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const LandingPage()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingPage()),
      GoRoute(path: '/login', builder: (context, state) => const StudentLoginPage()),
      GoRoute(path: '/login-educator', builder: (context, state) => const EducatorLoginPage()),
      GoRoute(path: '/register', builder: (context, state) => const StudentRegisterPage()),
      GoRoute(
        path: '/register-educator',
        builder: (context, state) => const EducatorRegisterPage(),
      ),
      GoRoute(
        path: '/student/avatar-select',
        builder: (context, state) => const AvatarSelectionPage(),
      ),
      GoRoute(
        path: '/student/enroll',
        builder: (context, state) => const EnrollmentPage(),
      ),

      ShellRoute(
        navigatorKey: _studentShellNavigatorKey,
        builder: (context, state, child) => StudentShell(child: child),
        routes: [
          GoRoute(path: '/student/home', builder: (context, state) => const StudentHomePage()),
          GoRoute(path: '/student/library', builder: (context, state) => const StoryLibraryPage()),
          GoRoute(path: '/student/search', builder: (context, state) => const StudentSearchPage()),
          GoRoute(path: '/student/progress', builder: (context, state) => const ProgressPage()),
          GoRoute(path: '/student/profile', builder: (context, state) => const StudentProfilePage()),
        ],
      ),
      GoRoute(
        path: '/student/story/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => StoryDetailsPage(storyId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/student/reader/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ReaderPage(storyId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/student/evaluation/:storyId/:type',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => EvaluationPage(
          storyId: state.pathParameters['storyId']!,
          type: state.pathParameters['type']!,
        ),
      ),

      ShellRoute(
        builder: (context, state, child) => EducatorShell(child: child),
        routes: [
          GoRoute(
            path: '/educator/home',
            builder: (context, state) => const EducatorHomePage(),
          ),
          GoRoute(
            path: '/educator/library',
            builder: (context, state) => const EducatorLibraryPage(),
          ),
          GoRoute(
            path: '/educator/search',
            builder: (context, state) => const EducatorSearchPage(),
          ),
          GoRoute(
            path: '/educator/school',
            builder: (context, state) =>
                const educator_school.EducatorSchoolSettingsPage(),
          ),
          GoRoute(path: '/educator/profile', builder: (context, state) => const EducatorProfilePage()),
        ],
      ),

      GoRoute(
        path: '/educator/questionnaire/:storyId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => QuestionnaireCreationPage(
          storyId: state.pathParameters['storyId']!,
        ),
      ),
      GoRoute(
        path: '/principal/educators',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PrincipalEducatorsPage(),
      ),
      GoRoute(
        path: '/principal/students',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PrincipalEnrolledStudentsPage(),
      ),
      GoRoute(
        path: '/principal/stories',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PrincipalStoryBooksPage(),
      ),
      GoRoute(
        path: '/educator/stories',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const StoryManagementPage(),
      ),
      GoRoute(
        path: '/educator/stories/new',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const StoryManagementPage(createMode: true),
      ),
      GoRoute(
        path: '/educator/stories/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => StoryManagementPage(storyId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/educator/story/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            StoryDetailsPage(storyId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/educator/story-readers/:storyId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => StoryReadersPage(
          storyId: state.pathParameters['storyId']!,
        ),
      ),
      GoRoute(
        path: '/educator/student/:userId/progress',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => StudentProgressView(
          studentId: state.pathParameters['userId']!,
        ),
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
    _removeAuth = ref.listen<AuthState>(authControllerProvider, (_, next) => notifyListeners()).close;
    _removeProfile = ref
        .listen<AsyncValue<StudentProfile>>(myStudentProfileProvider, (_, next) => notifyListeners())
        .close;
  }

  final Ref ref;
  late final void Function() _removeAuth;
  late final void Function() _removeProfile;

  @override
  void dispose() {
    _removeAuth();
    _removeProfile();
    super.dispose();
  }
}

