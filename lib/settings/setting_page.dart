import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:roomly/features/auth/data/repository/auth_gate.dart';
import 'package:roomly/features/auth/data/repository/authentication_repository.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = Get.find<AuthenticationRepository>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight + 16),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              // Profile Card (dynamic)
              Obx(() => _buildProfileCard(
                name: authRepo.firebaseUser.value?.displayName ?? 'User',
                email: authRepo.firebaseUser.value?.email ?? 'No email',
                photoUrl: authRepo.firebaseUser.value?.photoURL,
              )),
              const SizedBox(height: 32),

              // ACCOUNT Section
              _buildSectionTitle('ACCOUNT'),
              _buildSettingsGroup([
                _buildSettingsTile(
                  icon: Icons.person,
                  title: 'Personal Information',
                  onTap: () {
                    Get.snackbar('Info', 'Edit Profile coming soon');
                  },
                  showDivider: true,
                ),
              ]),

              const SizedBox(height: 10),
              // SUPPORT Section
              _buildSectionTitle('SUPPORT'),
              _buildSettingsGroup([
                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  onTap: () {
                    Get.snackbar('Info', 'Help Center coming soon');
                  },
                  showDivider: true,
                ),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final version =
                    snapshot.hasData ? 'v${snapshot.data!.version}' : 'v...';
                    return _buildSettingsTile(
                      icon: Icons.info_outline,
                      title: 'About',
                      value: version,
                      onTap: () {
                        Get.snackbar('About', 'Roomly App\nVersion $version');
                      },
                      showDivider: false,
                    );
                  },
                ),
              ]),
              const SizedBox(height: 20),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _confirmLogout(authRepo, context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Profile Card (no asset, uses initial-based avatar)
  // ------------------------------------------------------------
  Widget _buildProfileCard({
    required String name,
    required String email,
    String? photoUrl,
  }) {
    // Get initials from name or email
    String initials = '';
    if (name.isNotEmpty && name != 'User') {
      final parts = name.trim().split(' ');
      if (parts.isNotEmpty) initials = parts[0][0];
      if (parts.length > 1) initials += parts[1][0];
      initials = initials.toUpperCase();
    } else if (email.isNotEmpty) {
      initials = email[0].toUpperCase();
    } else {
      initials = 'U';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                ? NetworkImage(photoUrl)
                : null,
            child: (photoUrl == null || photoUrl.isEmpty)
                ? Text(
              initials,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  email,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Get.snackbar('Info', 'Edit Profile coming soon');
            },
            child: Row(
              children: const [
                Text('Edit Profile', style: TextStyle(color: Colors.blue)),
                Icon(Icons.chevron_right, color: Colors.blue, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // Section Title
  // ------------------------------------------------------------
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Settings Group (White Card)
  // ------------------------------------------------------------
  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }

  // ------------------------------------------------------------
  // Standard Settings Tile
  // ------------------------------------------------------------
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? value,
    required VoidCallback onTap,
    bool showDivider = true,
    bool isDanger = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDanger
                  ? Colors.red.withOpacity(0.05)
                  : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isDanger ? Colors.red : Colors.blue,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDanger ? Colors.red : Colors.black,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value != null)
                Text(
                  value,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(height: 1, indent: 60, color: Colors.grey.shade100),
      ],
    );
  }

  // ------------------------------------------------------------
  // Logout Confirmation Dialog (fixed navigation)
  // ------------------------------------------------------------
  void _confirmLogout(AuthenticationRepository authRepo, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await authRepo.logout();
              Get.offAll(() => const AuthGate());
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}