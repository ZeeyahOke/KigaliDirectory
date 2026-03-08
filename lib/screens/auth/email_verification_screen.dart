import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../home_screen.dart';
import 'login_screen.dart';

/// Screen shown after signup (or login with unverified email).
///
/// Users must verify their email before proceeding to the main app.
/// Provides a "Resend Email" button and an "I've Verified" button
/// that reloads the user's Firebase profile to check verification status.
class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.scaffoldBg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Email icon
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_outlined,
                    color: AppConstants.primaryColor,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 28),

                const Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryDark,
                  ),
                ),
                const SizedBox(height: 12),

                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return Text(
                      'We sent a verification link to\n${auth.user?.email ?? "your email"}.\n\nPlease check your inbox and click the link to verify your account.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 36),

                // "I've Verified" button
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: auth.isLoading
                            ? null
                            : () async {
                                final verified =
                                    await auth.checkEmailVerification();
                                if (!context.mounted) return;

                                if (verified) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (_) => const HomeScreen()),
                                    (route) => false,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Email not yet verified. Please check your inbox.',
                                      ),
                                      backgroundColor: AppConstants.errorColor,
                                    ),
                                  );
                                }
                              },
                        icon: auth.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline),
                        label: Text(
                          auth.isLoading ? 'Checking...' : "I've Verified My Email",
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),

                // Resend email button
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: auth.isLoading
                            ? null
                            : () async {
                                final sent =
                                    await auth.resendVerificationEmail();
                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      sent
                                          ? 'Verification email resent successfully!'
                                          : 'Failed to resend. Please try again.',
                                    ),
                                    backgroundColor: sent
                                        ? AppConstants.successColor
                                        : AppConstants.errorColor,
                                  ),
                                );
                              },
                        icon: const Icon(Icons.email_outlined),
                        label: const Text(
                          'Resend Verification Email',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppConstants.primaryColor,
                          side: const BorderSide(
                            color: AppConstants.primaryColor,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),

                // Back to login
                GestureDetector(
                  onTap: () async {
                    await context.read<AuthProvider>().signOut();
                    if (!context.mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  child: Text(
                    'Back to Login',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
