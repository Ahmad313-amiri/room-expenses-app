import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:roomly/features/auth/data/repository/authentication_repository.dart';

import '../../../../settings/settings_controller.dart';
import '../../../../settings/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = Get.find<AuthenticationRepository>();
    final settingsController = Get.find<SettingsController>();
    final themeController = Get.find<ThemeController>();

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
                    // TODO: Navigate to Edit Profile Screen
                    Get.snackbar('Info', 'Edit Profile coming soon');
                  },
                  showDivider: true,
                ),
              ]),

              const SizedBox(height: 15),

              // PREFERENCES Section
              _buildSectionTitle('PREFERENCES'),
              _buildSettingsGroup([
                // Primary Currency (dynamic)
                Obx(() => _buildSettingsTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Primary Currency',
                  value: settingsController.primaryCurrency.value,
                  onTap: () => _showCurrencyPicker(settingsController),
                  showDivider: true,
                )),
                // Dark Mode (dynamic)
                Obx(() => _buildDarkModeTile(
                  isDarkMode: themeController.isDarkMode.value,
                  onChanged: (_) => themeController.toggleTheme(),
                )),
              ]),

              const SizedBox(height: 10),

              // SUPPORT Section
              _buildSectionTitle('SUPPORT'),
              _buildSettingsGroup([
                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  onTap: () {
                    // TODO: Open help center
                    Get.snackbar('Info', 'Help Center coming soon');
                  },
                  showDivider: true,
                ),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final version = snapshot.hasData
                        ? 'v${snapshot.data!.version}'
                        : 'v...';
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
              //
              const SizedBox(height: 20),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _confirmLogout(authRepo),
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
  // Profile Card
  // ------------------------------------------------------------
  Widget _buildProfileCard({
    required String name,
    required String email,
    String? photoUrl,
  }) {
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
            backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                ? NetworkImage(photoUrl)
                : const AssetImage('assets/default_avatar.png') as ImageProvider,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              // TODO: Navigate to edit profile
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
  // Dark Mode Tile
  // ------------------------------------------------------------
  Widget _buildDarkModeTile({
    required bool isDarkMode,
    required Function(bool) onChanged,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.dark_mode, color: Colors.blue, size: 20),
          ),
          title: const Text(
            'Dark Mode',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          trailing: Switch.adaptive(
            value: isDarkMode,
            onChanged: onChanged,
            activeColor: Colors.blue,
          ),
        ),
        Divider(height: 1, indent: 60, color: Colors.grey.shade100),
      ],
    );
  }

  // ------------------------------------------------------------
  // Currency Picker Bottom Sheet
  // ------------------------------------------------------------
  void _showCurrencyPicker(SettingsController controller) {
    showModalBottomSheet(
      context: Get.context!,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('USD (\$)'),
              onTap: () {
                controller.setPrimaryCurrency('USD (\$)');
                Get.back();
              },
            ),
            ListTile(
              title: const Text('EUR (€)'),
              onTap: () {
                controller.setPrimaryCurrency('EUR (€)');
                Get.back();
              },
            ),
            ListTile(
              title: const Text('AFN (؋)'),
              onTap: () {
                controller.setPrimaryCurrency('AFN (؋)');
                Get.back();
              },
            ),
            ListTile(
              title: const Text('IRR (﷼)'),
              onTap: () {
                controller.setPrimaryCurrency('IRR (﷼)');
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Logout Confirmation Dialog
  // ------------------------------------------------------------
  void _confirmLogout(AuthenticationRepository authRepo) {
    Get.dialog(
      AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Get.back(); // close dialog
              await authRepo.logout();
              // Navigate to login screen (you may need to adjust)
              Get.offAllNamed('/login');
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}