import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:forest/firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'constants/app_constants.dart';
import 'services/firebase_service.dart';
import 'services/auth_service.dart';
import 'services/settings_service.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/data_collection_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/admin_home_screen.dart';
import 'screens/missions_screen.dart';
import 'screens/analysis_screen.dart';
import 'screens/error_management_screen.dart';
import 'screens/backup_management_screen.dart';
import 'screens/forest_zones_management_screen.dart';
import 'screens/role_based_home_screen.dart';
import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initializeFirebase();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final auth = AuthService();
  final sessionUser = await auth.restoreSession();

  final settings = SettingsService();
  await settings.init(userId: sessionUser?.id);

  runApp(
    ChangeNotifierProvider.value(
      value: settings,
      child: ForestApp(
        hasSession: sessionUser != null,
        isAdmin: (sessionUser?.email ?? '').toLowerCase() == 'admin@gmail.com',
      ),
    ),
  );
}

class ForestApp extends StatelessWidget {
  final bool hasSession;
  final bool isAdmin;
  const ForestApp({super.key, required this.hasSession, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();

    final ThemeData baseDark = ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppConstants.primaryGreen,
      scaffoldBackgroundColor: AppConstants.primaryBlack,
      colorScheme: const ColorScheme.dark(
        primary: AppConstants.primaryGreen,
        surface: AppConstants.primaryBlack,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.primaryBlack,
        foregroundColor: AppConstants.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppConstants.primaryBlack,
        selectedItemColor: AppConstants.primaryGreen,
        unselectedItemColor: AppConstants.textGrey,
      ),
    );

    final ThemeData baseLight = ThemeData(
      brightness: Brightness.light,
      primaryColor: AppConstants.primaryGreen,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: AppConstants.primaryGreen,
        surface: Colors.white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.primaryBlack,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppConstants.primaryGreen,
        unselectedItemColor: Colors.black45,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: settings.darkMode ? baseDark : baseLight,
      initialRoute:
          hasSession ? (isAdmin ? '/admin-home' : '/home') : '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const RoleBasedHomeScreen(),
        '/admin': (context) => const AdminScreen(),
        '/admin-home': (context) => const AdminHomeScreen(),
        '/inventory': (context) => const InventoryScreen(),
        '/data-collection': (context) => const DataCollectionScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/missions':
            (context) => MissionsScreen(
              currentUser: UserModel(
                id: '',
                email: '',
                firstName: '',
                lastName: '',
                username: '',
                dateJoined: DateTime.now(),
              ),
            ),
        '/analysis':
            (context) => AnalysisScreen(
              currentUser: UserModel(
                id: '',
                email: '',
                firstName: '',
                lastName: '',
                username: '',
                dateJoined: DateTime.now(),
              ),
            ),
        '/error-management':
            (context) => ErrorManagementScreen(
              currentUser: UserModel(
                id: '',
                email: '',
                firstName: '',
                lastName: '',
                username: '',
                dateJoined: DateTime.now(),
              ),
            ),
        '/backup-management':
            (context) => BackupManagementScreen(
              currentUser: UserModel(
                id: '',
                email: '',
                firstName: '',
                lastName: '',
                username: '',
                dateJoined: DateTime.now(),
              ),
            ),
        '/forest-zones-management':
            (context) => ForestZonesManagementScreen(
              currentUser: UserModel(
                id: '',
                email: '',
                firstName: '',
                lastName: '',
                username: '',
                dateJoined: DateTime.now(),
              ),
            ),
      },
    );
  }
}
