import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.paperDim, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.pine,
                    child: Text(
                      user != null && user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: AppTextStyles.display(22, color: AppColors.paper),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? '', style: AppTextStyles.body(16, weight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(user?.email ?? '', style: AppTextStyles.body(13, color: AppColors.mutedInk)),
                        if (user?.phone != null && user!.phone!.isNotEmpty)
                          Text(user.phone!, style: AppTextStyles.body(13, color: AppColors.mutedInk)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: AppColors.clay),
                  foregroundColor: AppColors.clay,
                ),
                onPressed: () async {
                  // RootShell watches AuthProvider and swaps to the login
                  // view automatically once isAuthenticated flips to false.
                  await context.read<AuthProvider>().logout();
                },
                child: const Text('Log out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
