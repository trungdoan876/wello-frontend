import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/domain/providers/question_provider.dart';
import 'package:wello_frontend/domain/providers/survey_provider.dart';
import 'package:wello_frontend/domain/providers/nutrition_provider.dart';
import 'package:wello_frontend/domain/providers/profile_provider.dart';
import 'package:wello_frontend/domain/providers/favorites_provider.dart';
import 'package:wello_frontend/domain/providers/sleep_provider.dart';
import 'package:wello_frontend/domain/providers/running_provider.dart';
import 'package:wello_frontend/ui/auth/initial_page.dart';
import 'package:wello_frontend/core/services/firebase_service.dart';
import 'package:wello_frontend/core/services/notification_service.dart';
import 'package:wello_frontend/core/navigation/route_observer.dart';
import 'package:wello_frontend/data/repositories/streak_repository_impl.dart';
import 'package:wello_frontend/data/data_source/streak_remote_data_source.dart';
import 'package:wello_frontend/domain/providers/streak_provider.dart';
import 'package:wello_frontend/domain/providers/community_provider.dart';
import 'package:wello_frontend/domain/providers/competition_provider.dart';
import 'package:wello_frontend/domain/providers/notification_provider.dart';
import 'package:wello_frontend/data/repositories/post_repository_impl.dart';
import 'package:wello_frontend/data/data_source/post_remote_data_source.dart';
import 'package:wello_frontend/data/repositories/competition_repository_impl.dart';
import 'package:wello_frontend/data/data_source/competition_remote_data_source.dart';
import 'package:wello_frontend/domain/providers/contribution_provider.dart';
import 'package:wello_frontend/data/repositories/food_repository_impl.dart';
import 'package:wello_frontend/data/data_source/food_remote_data_source.dart';
import 'package:wello_frontend/data/repositories/exercise_repository_impl.dart';
import 'package:wello_frontend/data/data_source/exercise_remote_data_source.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-load Baloo2 font để tránh lỗi font khi không có internet
  await GoogleFonts.pendingFonts([
    GoogleFonts.baloo2(),
  ]);

  // Khởi tạo Firebase
  await FirebaseService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuestionProvider()),
        ChangeNotifierProvider(create: (_) => SurveyProvider()),
        ChangeNotifierProvider(create: (_) => NutritionProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => SleepProvider()),
        ChangeNotifierProvider(create: (_) => RunningProvider()),
        ChangeNotifierProvider(
          create: (_) => ContributionProvider(
            foodRepository: FoodRepositoryImpl(
              remoteDataSource: FoodRemoteDataSource(),
            ),
            exerciseRepository: ExerciseRepositoryImpl(
              remoteDataSource: ExerciseRemoteDataSource(),
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => StreakProvider(
            StreakRepositoryImpl(
              StreakRemoteDataSource(),
            ),
          ),
        ),
        ChangeNotifierProvider(create: (_) => CommunityProvider(
          PostRepositoryImpl(
            PostRemoteDataSource(),
          ),
        )),
        ChangeNotifierProvider(create: (_) => CompetitionProvider(
          CompetitionRepositoryImpl(
            remoteDataSource: CompetitionRemoteDataSource(),
          ),
        )),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: FirebaseService.navigatorKey,
      title: 'My Wello',
      theme: ThemeData(
        primarySwatch: Colors.blue,

        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      debugShowCheckedModeBanner: false,
      navigatorObservers: [appRouteObserver],
      // Restore the normal app entry flow
      home: const InitialPage(),
    );
  }
}
