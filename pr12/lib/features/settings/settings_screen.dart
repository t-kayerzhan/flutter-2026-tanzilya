import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../profile/profile_screen.dart';
import '../auth/auth_model.dart';
import '../users/users_model.dart';
import 'settings_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    final users = context.watch<UsersModel>();

    final cities = users.items.map((user) => user.address.city).toSet().toList()
      ..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            subtitle: const Text('Save theme after restart'),
            value: settings.dark,
            onChanged: (value) {
              settings.setDark(value);
            },
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              key: ValueKey(settings.city),
              initialValue: cities.contains(settings.city)
                  ? settings.city
                  : null,
              decoration: const InputDecoration(
                labelText: 'City filter',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All cities'),
                ),
                for (final city in cities)
                  DropdownMenuItem<String>(value: city, child: Text(city)),
              ],
              onChanged: (value) {
                settings.setCity(value);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Profile'),
            subtitle: const Text('Camera and gallery'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () async {
              await context.read<AuthModel>().logout();

              if (!context.mounted) return;

              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
