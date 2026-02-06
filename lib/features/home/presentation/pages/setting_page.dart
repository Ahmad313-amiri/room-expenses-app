import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Controls Dark Mode switch state
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Light gray background for the whole screen
      backgroundColor: const Color(0xFFF7F8FA),

      // Top AppBar styled similar to iOS
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        // Custom back button (icon + text)
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 18,
            color: Colors.blue,
          ),
          label: const Text(
            'Back',
            style: TextStyle(color: Colors.blue, fontSize: 16),
          ),
        ),

        // Page title
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Main scrollable content
      body: Padding(
        padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight + 16),
        child: ListView(

          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            // Profile card at the top
            _buildProfileCard(),
            const SizedBox(height: 32),

            // ACCOUNT section
            _buildSectionTitle('ACCOUNT'),
            _buildSettingsGroup([
              _buildSettingsTile(
                Icons.person,
                'Personal Information',
                null,
                true,
              ),
              _buildSettingsTile(
                Icons.shield_outlined,
                'Privacy & Security',
                null,
                false,
              ),
            ]),

            const SizedBox(height: 24),

            // PREFERENCES section
            _buildSectionTitle('PREFERENCES'),
            _buildSettingsGroup([
              _buildSettingsTile(
                Icons.account_balance_wallet_outlined,
                'Primary Currency',
                'USD (\$)',
                true,
              ),
              _buildDarkModeTile(),
              _buildSettingsTile(
                Icons.notifications_none,
                'Notifications',
                null,
                false,
              ),
            ]),

            const SizedBox(height: 24),

            // DATA MANAGEMENT section
            _buildSectionTitle('DATA MANAGEMENT'),
            _buildSettingsGroup([
              _buildSettingsTile(
                Icons.file_upload_outlined,
                'Export Data',
                'CSV / PDF',
                true,
                isBadge: true,
              ),
              _buildSettingsTile(
                Icons.cloud_off_outlined,
                'Backup & Restore',
                'OFFLINE ONLY',
                true,
                subValueColor: Colors.green,
              ),
              _buildSettingsTile(
                Icons.delete_outline,
                'Clear All Data',
                null,
                false,
                isDanger: true,
              ),
            ]),

            const SizedBox(height: 24),

            // SUPPORT section
            _buildSectionTitle('SUPPORT'),
            _buildSettingsGroup([
              _buildSettingsTile(
                Icons.help_outline,
                'Help Center',
                null,
                true,
              ),
              _buildSettingsTile(
                Icons.info_outline,
                'About',
                'v2.4.0',
                false,
              ),
            ]),

            const SizedBox(height: 40),

            // Logout button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
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

            const SizedBox(height: 20),

            // Footer text
            const Center(
              child: Text(
                'Debt Manager - Secure Offline Storage',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Builds the profile card shown at the top of the settings screen
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Profile avatar image
          const CircleAvatar(
            radius: 35,
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/150?u=alex',
            ),
          ),

          const SizedBox(width: 16),

          // User name and email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Alex Johnson',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'alex.j@example.com',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Edit profile action
          TextButton(
            onPressed: () {},
            child: Row(
              children: const [
                Text(
                  'Edit Profile',
                  style: TextStyle(color: Colors.blue),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.blue,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Builds section titles like ACCOUNT, PREFERENCES, etc.
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

  // Wraps a group of setting tiles inside a rounded white card
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

  // Builds a single settings row (icon + title + value)
  Widget _buildSettingsTile(
      IconData icon,
      String title,
      String? value,
      bool showDivider, {
        bool isBadge = false,
        Color? subValueColor,
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

          // Title text
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDanger ? Colors.red : Colors.black,
            ),
          ),

          // Right side value + arrow
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value != null)
                Container(
                  padding: isBadge
                      ? const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  )
                      : EdgeInsets.zero,
                  decoration: isBadge
                      ? BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  )
                      : null,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: subValueColor ??
                          (isBadge ? Colors.blue : Colors.grey),
                      fontSize: 13,
                      fontWeight:
                      isBadge ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),

              // Chevron icon (not shown for danger actions)
              if (!isDanger)
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 20,
                ),
            ],
          ),
          onTap: () {},
        ),

        // Optional divider between rows
        if (showDivider)
          Divider(
            height: 1,
            indent: 60,
            color: Colors.grey.shade100,
          ),
      ],
    );
  }

  // Special settings row that contains the Dark Mode switch
  Widget _buildDarkModeTile() {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.dark_mode,
              color: Colors.blue,
              size: 20,
            ),
          ),
          title: const Text(
            'Dark Mode',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Adaptive switch (iOS / Android)
          trailing: Switch.adaptive(
            value: isDarkMode,
            onChanged: (val) => setState(() => isDarkMode = val),
            activeColor: Colors.blue,
          ),
        ),

        // Divider below the tile
        Divider(
          height: 1,
          indent: 60,
          color: Colors.grey.shade100,
        ),
      ],
    );
  }
}
