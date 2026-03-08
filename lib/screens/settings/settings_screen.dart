import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';

/// Settings screen displaying user profile info, notification toggle,
/// seed data utility, and logout.
///
/// All data comes from [AuthProvider] and [SettingsProvider] — no
/// direct Firebase calls.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.scaffoldBg,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── User Profile Card ────────────────────────────────────────
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final profile = auth.userProfile;
                final user = auth.user;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            (
                              (profile?.displayName ?? user?.displayName ?? '').isNotEmpty
                                ? (profile?.displayName ?? user?.displayName ?? 'U').substring(0, 1)
                                : 'U'
                            )
                                .toUpperCase(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        profile?.displayName ??
                            user?.displayName ??
                            'User',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile?.email ?? user?.email ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified,
                                size: 14, color: AppConstants.successColor),
                            SizedBox(width: 4),
                            Text(
                              'Email Verified',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppConstants.successColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // ── Preferences Section ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 14, 16, 4),
                    child: Text(
                      'Preferences',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  Consumer<SettingsProvider>(
                    builder: (context, settings, _) {
                      return SwitchListTile(
                        title: const Text('Location-based Notifications'),
                        subtitle: Text(
                          settings.locationNotificationsEnabled
                              ? 'Receive alerts for nearby services'
                              : 'Notifications disabled',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        value: settings.locationNotificationsEnabled,
                        onChanged: (value) =>
                            settings.toggleLocationNotifications(value),
                        activeThumbColor: AppConstants.primaryColor,
                        secondary: Icon(
                          settings.locationNotificationsEnabled
                              ? Icons.notifications_active_outlined
                              : Icons.notifications_off_outlined,
                          color: AppConstants.primaryColor,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Actions Section ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 14, 16, 4),
                    child: Text(
                      'Actions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),

                  // Seed sample data
                  ListTile(
                    leading: const Icon(Icons.dataset_outlined,
                        color: AppConstants.primaryColor),
                    title: const Text('Seed Sample Data'),
                    subtitle: Text(
                      'Add 10 sample Kigali listings',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                    trailing: Consumer<ListingsProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoading) {
                          return const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        }
                        return const Icon(Icons.chevron_right);
                      },
                    ),
                    onTap: () => _handleSeedData(context),
                  ),

                  const Divider(height: 1, indent: 16, endIndent: 16),

                  // Logout
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppConstants.errorColor),
                    title: const Text(
                      'Log Out',
                      style: TextStyle(color: AppConstants.errorColor),
                    ),
                    onTap: () => _handleLogout(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // App version
            Text(
              'Kigali Directory v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSeedData(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final listingsProvider = context.read<ListingsProvider>();

    if (auth.user == null) return;

    final success = await listingsProvider.seedData(auth.user!.uid);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Sample data added successfully!'
                : 'Failed to seed data.',
          ),
          backgroundColor:
              success ? AppConstants.successColor : AppConstants.errorColor,
        ),
      );
    }
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
