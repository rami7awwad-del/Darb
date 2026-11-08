// PASTE AS: test/app_test.dart  (project root, next to lib/)
//
// Uses only flutter_test + flutter_bloc (already in your project).
// No mocktail / bloc_test needed: repositories are replaced with tiny fakes.
//
// Run:  flutter test test/app_test.dart

import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/routing/app_routes.dart';
import 'package:darb/features/home/data/models/course_model.dart';
import 'package:darb/features/home/data/models/home_data_model.dart';
import 'package:darb/features/home/data/repositories/home_repository.dart';
import 'package:darb/features/home/presentation/cubit/home_cubit.dart';
import 'package:darb/features/home/presentation/screens/home_screen.dart';
import 'package:darb/features/home/presentation/widgets/courses_section.dart';
import 'package:darb/features/home/presentation/widgets/curriculum_progress_card.dart';
import 'package:darb/features/profile/data/models/profile_model.dart';
import 'package:darb/features/profile/data/repositories/profile_repository.dart';
import 'package:darb/features/subscription/presentation/subscription_access.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

// ---------------------------------------------------------------------------
// Test data & fakes
// ---------------------------------------------------------------------------

const _subscribedCourse = CourseModel(
  id: 1,
  name: 'subscribed',
  courseName: 'Subscribed Course',
  professor: 'Prof A',
  image: '',
  isSubscription: true,
);

const _lockedCourse = CourseModel(
  id: 2,
  name: 'locked',
  courseName: 'Locked Course',
  professor: 'Prof B',
  image: '',
);

const _freeCourse = CourseModel(
  id: 3,
  name: 'free',
  courseName: 'Free Course',
  professor: 'Prof C',
  image: '',
  isFree: true,
);

const _profile = ProfileModel(
  id: 1,
  firstName: 'Test',
  lastName: 'User',
  phone: '0000000000',
);

/// Fake [HomeRepository]: returns canned data and counts `getHome` calls.
class _FakeHomeRepository implements HomeRepository {
  _FakeHomeRepository({this.fail = false});

  final bool fail;
  int getHomeCalls = 0;

  @override
  Future<HomeDataModel> getHome() async {
    getHomeCalls++;
    if (fail) throw Exception('boom');
    return const HomeDataModel(
      subjects: [],
      news: [],
      courses: [_subscribedCourse, _lockedCourse],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fake [ProfileRepository].
class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<ProfileModel> getProfile() async => _profile;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// Widget-test helpers
// ---------------------------------------------------------------------------

/// Pushed instead of the real screens (the real ones need repositories).
/// Shows its route name so tests can assert where navigation went.
class _StubPage extends StatelessWidget {
  const _StubPage(this.name, {this.popValue});

  final String name;
  final bool? popValue;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(
          children: [
            Text('page:$name'),
            if (popValue != null)
              TextButton(
                onPressed: () => Navigator.pop(context, popValue),
                child: const Text('finish'),
              ),
          ],
        ),
      );
}

/// Route table used by the widget tests. [subscribeResult] is what the fake
/// subscription page returns when its "finish" button is tapped.
Route<dynamic> _stubRoutes(RouteSettings settings, {bool? subscribeResult}) {
  return MaterialPageRoute<bool?>(
    settings: settings,
    builder: (_) => _StubPage(
      settings.name ?? '',
      popValue: settings.name == AppRoutes.subscription ? subscribeResult : null,
    ),
  );
}

/// Wraps [child] with ScreenUtil + RTL MaterialApp + the stub routes.
///
/// Design size equals the test surface (800x1600) so ScreenUtil scales 1:1.
/// That keeps the layout roomy, because tests render text with the wide "Ahem"
/// font and a phone-sized surface could cause false overflow errors.
Widget _app(Widget child, {bool? subscribeResult}) => ScreenUtilInit(
      designSize: const Size(800, 1600),
      builder: (_, _) => MaterialApp(
        // The real app is Arabic/RTL; mirror that without extra delegates.
        builder: (context, child) =>
            Directionality(textDirection: TextDirection.rtl, child: child!),
        home: child,
        onGenerateRoute: (s) => _stubRoutes(s, subscribeResult: subscribeResult),
      ),
    );

void _useBigSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Pumps the real [HomeScreen] with fake repositories.
Future<_FakeHomeRepository> _pumpHome(
  WidgetTester tester, {
  bool? subscribeResult,
}) async {
  _useBigSurface(tester);
  final homeRepo = _FakeHomeRepository();

  await tester.pumpWidget(
    _app(
      BlocProvider(
        create: (_) => HomeCubit(homeRepo, _FakeProfileRepository())..load(),
        child: const Scaffold(body: HomeScreen()),
      ),
      subscribeResult: subscribeResult,
    ),
  );
  await tester.pumpAndSettle();
  return homeRepo;
}

/// Scrolls the home list until [finder] is on screen.
Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: find
        .descendant(
          of: find.byType(RefreshIndicator),
          matching: find.byType(Scrollable),
        )
        .first,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ---------------- Unit tests ----------------
  group('CourseModel', () {
    test('fromJson maps subscription flags', () {
      final course = CourseModel.fromJson({
        'id': 7,
        'name': 'n',
        'course_name': 'Course',
        'professor': 'P',
        'image': 'x.png',
        'is_free': false,
        'is_subscription': true,
      });

      expect(course.id, 7);
      expect(course.courseName, 'Course');
      expect(course.isSubscription, isTrue);
      expect(course.isFree, isFalse);
    });

    test('fromJson falls back to safe defaults', () {
      final course = CourseModel.fromJson({'id': 1});

      expect(course.isSubscription, isFalse);
      expect(course.isFree, isFalse);
      expect(course.lessonsCount, 0);
      expect(course.courseName, '');
    });
  });

  group('hasCourseAccess', () {
    test('subscribed course is accessible', () {
      expect(hasCourseAccess(_subscribedCourse), isTrue);
    });

    test('free course is accessible', () {
      expect(hasCourseAccess(_freeCourse), isTrue);
    });

    test('unsubscribed, non-free course is NOT accessible', () {
      expect(hasCourseAccess(_lockedCourse), isFalse);
    });
  });

  group('HomeData', () {
    test('isSearching depends on the query', () {
      expect(const HomeData().isSearching, isFalse);
      expect(const HomeData(query: 'math').isSearching, isTrue);
    });

    test('copyWith keeps untouched fields', () {
      final data = const HomeData(query: 'a').copyWith(profile: _profile);

      expect(data.query, 'a');
      expect(data.profile, _profile);
    });
  });

  group('HomeCubit', () {
    test('load success -> loaded with profile and home data', () async {
      final cubit = HomeCubit(_FakeHomeRepository(), _FakeProfileRepository());
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state.stateValue, StateValue.loaded);
      expect(cubit.state.data!.profile, _profile);
      expect(cubit.state.data!.home!.courses, hasLength(2));
    });

    test('load failure -> error state', () async {
      final cubit = HomeCubit(
        _FakeHomeRepository(fail: true),
        _FakeProfileRepository(),
      );
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state.stateValue, StateValue.error);
      expect(cubit.state.errorMessage, isNotNull);
    });

    test('clearing the search text leaves search mode', () async {
      final cubit = HomeCubit(_FakeHomeRepository(), _FakeProfileRepository());
      addTearDown(cubit.close);

      cubit.onSearchChanged('math');
      expect(cubit.state.data!.isSearching, isTrue);

      cubit.onSearchChanged('   ');
      expect(cubit.state.data!.isSearching, isFalse);
      expect(cubit.state.data!.searchStatus, SearchStatus.idle);
    });
  });

  // ---------------- Widget tests: isolated widgets ----------------
  group('Isolated widget callbacks', () {
    testWidgets('CurriculumProgressCard: tapping "التفاصيل" calls onDetails',
        (tester) async {
      _useBigSurface(tester);
      var taps = 0;

      await tester.pumpWidget(
        _app(
          Scaffold(
            body: CurriculumProgressCard(
              percent: 40,
              coursesCount: 3,
              onDetails: () => taps++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('التفاصيل'));
      expect(taps, 1);
    });

    testWidgets('CoursesSection: tapping a card reports that course',
        (tester) async {
      _useBigSurface(tester);
      CourseModel? tapped;

      await tester.pumpWidget(
        _app(
          Scaffold(
            body: CoursesSection(
              courses: const [_subscribedCourse, _lockedCourse],
              onCourseTap: (c) => tapped = c,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Locked Course'));
      expect(tapped, _lockedCourse);
    });
  });

  // ---------------- Widget tests: HomeScreen navigation ----------------
  group('HomeScreen navigation', () {
    testWidgets('medal icon opens the achievements page', (tester) async {
      await _pumpHome(tester);

      await tester.tap(find.byIcon(PhosphorIconsRegular.medal));
      await tester.pumpAndSettle();

      expect(find.text('page:${AppRoutes.achievements}'), findsOneWidget);
    });

    testWidgets('"التفاصيل" in the card under the search bar opens achievements',
        (tester) async {
      await _pumpHome(tester);

      await tester.tap(find.text('التفاصيل'));
      await tester.pumpAndSettle();

      expect(find.text('page:${AppRoutes.achievements}'), findsOneWidget);
    });

    testWidgets('subscribed course opens course details directly',
        (tester) async {
      await _pumpHome(tester);
      await _scrollTo(tester, find.text('Subscribed Course'));

      await tester.tap(find.text('Subscribed Course'));
      await tester.pumpAndSettle();

      expect(find.text('page:${AppRoutes.courseDetails}'), findsOneWidget);
      expect(find.text('page:${AppRoutes.subscription}'), findsNothing);
    });

    testWidgets('NOT subscribed course opens the subscription page',
        (tester) async {
      await _pumpHome(tester);
      await _scrollTo(tester, find.text('Locked Course'));

      await tester.tap(find.text('Locked Course'));
      await tester.pumpAndSettle();

      expect(find.text('page:${AppRoutes.subscription}'), findsOneWidget);
      expect(find.text('page:${AppRoutes.courseDetails}'), findsNothing);
    });

    testWidgets(
        'leaving the subscription page without subscribing does not open the course',
        (tester) async {
      await _pumpHome(tester, subscribeResult: false);
      await _scrollTo(tester, find.text('Locked Course'));

      await tester.tap(find.text('Locked Course'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('finish'));
      await tester.pumpAndSettle();

      expect(find.text('page:${AppRoutes.courseDetails}'), findsNothing);
    });

    testWidgets(
        'subscribing from the paywall refreshes home and opens the course',
        (tester) async {
      final homeRepo = await _pumpHome(tester, subscribeResult: true);
      final callsBefore = homeRepo.getHomeCalls;
      await _scrollTo(tester, find.text('Locked Course'));

      await tester.tap(find.text('Locked Course'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('finish'));
      await tester.pumpAndSettle();

      expect(find.text('page:${AppRoutes.courseDetails}'), findsOneWidget);
      expect(homeRepo.getHomeCalls, greaterThan(callsBefore));
    });
  });

  // Keeps the BaseState import meaningful: the cubit state is a BaseState.
  test('HomeCubit starts in loading state', () {
    final cubit = HomeCubit(_FakeHomeRepository(), _FakeProfileRepository());
    addTearDown(cubit.close);

    expect(cubit.state, isA<BaseState<HomeData>>());
    expect(cubit.state.stateValue, StateValue.loading);
  });
}
