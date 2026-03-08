import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/listings_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

/// Application entry point.
///
/// Initializes Firebase, registers providers, and determines the initial
/// screen based on authentication and email verification state.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const KigaliDirectoryApp());
}

class KigaliDirectoryApp extends StatelessWidget {
  const KigaliDirectoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ListingsProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: AppConstants.primaryColor,
          scaffoldBackgroundColor: AppConstants.scaffoldBg,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            // Not logged in
            if (!auth.isAuthenticated) {
              return const LoginScreen();
            }

            // Logged in but email not verified
            if (!auth.isEmailVerified) {
              return const EmailVerificationScreen();
            }

            // Fully authenticated
            return const HomeScreen();
          },
        ),
      ),
    );
  }
}
