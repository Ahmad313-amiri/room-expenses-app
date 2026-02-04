

import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      // Settings app bar
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: ListView(
        children: [
          const SizedBox(height: 20),

          // Account section
          _buildMenuSection('ACCOUNT', [
            _buildMenuItem(Icons.person_outline, 'Edit Profile', null),
            _buildMenuItem(
              Icons.account_balance_wallet_outlined,
              'My Wallets',
              '3 Active',
            ),
          ]),

          // Preferences section
          _buildMenuSection('PREFERENCES', [
            _buildMenuItem(
              Icons.currency_exchange,
              'Primary Currency',
              'AFN',
            ),
            _buildMenuItem(Icons.language, 'Language', 'English'),
            _buildMenuItem(Icons.dark_mode_outlined, 'Dark Mode', 'Off'),
          ]),

          // Data & privacy section
          _buildMenuSection('DATA & PRIVACY', [
            _buildMenuItem(
              Icons.file_download_outlined,
              'Export Data (CSV/PDF)',
              null,
            ),
            _buildMenuItem(
              Icons.cloud_upload_outlined,
              'Manual Backup',
              null,
            ),
          ]),

          const SizedBox(height: 30),

          // Logout button
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Menu section wrapper
Widget _buildMenuSection(String title, List<Widget> items) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 20, top: 20, bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
      Container(
        color: Colors.white,
        child: Column(children: items),
      ),
    ],
  );
}

// Single settings menu item
Widget _buildMenuItem(
    IconData icon,
    String title,
    String? trailing,
    ) {
  return ListTile(
    leading: Icon(icon, color: Colors.blue, size: 22),

    title: Text(
      title,
      style: const TextStyle(fontSize: 15),
    ),

    // Trailing value + arrow
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (trailing != null)
          Text(
            trailing,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      ],
    ),

    onTap: () {},
  );
}
