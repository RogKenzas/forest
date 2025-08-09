import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants/app_constants.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/data_collection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppConstants.primaryGreen,
        scaffoldBackgroundColor: AppConstants.primaryBlack,
        colorScheme: const ColorScheme.dark(
          primary: AppConstants.primaryGreen,
          secondary: AppConstants.primaryGreen,
          surface: AppConstants.darkGrey,
          background: AppConstants.primaryBlack,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: AppConstants.white,
            displayColor: AppConstants.white,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.primaryBlack,
          foregroundColor: AppConstants.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppConstants.darkGrey,
          selectedItemColor: AppConstants.primaryGreen,
          unselectedItemColor: AppConstants.textGrey,
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/inventory': (context) => const InventoryScreen(),
        '/data-collection': (context) => const DataCollectionScreen(),
      },
    );
  }
}
