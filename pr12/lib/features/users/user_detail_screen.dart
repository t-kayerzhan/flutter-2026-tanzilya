import 'package:flutter/material.dart';

import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(title: const Text('ID'), subtitle: Text('${user.id}')),
          ListTile(
            title: const Text('Username'),
            subtitle: Text(user.username),
          ),
          ListTile(title: const Text('Email'), subtitle: Text(user.email)),
          ListTile(
            title: const Text('Address'),
            subtitle: Text(
              '${user.address.street}, ${user.address.suite}\n'
              '${user.address.city}, ${user.address.zipcode}',
            ),
          ),
          ListTile(
            title: const Text('Coordinates'),
            subtitle: Text('${user.address.geo.lat}, ${user.address.geo.lng}'),
          ),
          ListTile(
            title: const Text('Company'),
            subtitle: Text(
              '${user.company.name}\n${user.company.catchPhrase}\n${user.company.bs}',
            ),
          ),
          ListTile(
            title: const Text('Phone (tap action reserved for Practice 12)'),
            subtitle: Text('${user.phone}\nDigits: ${user.phoneDigits}'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Website (tap action reserved for Practice 12)'),
            subtitle: Text(user.website ?? 'Not provided'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
