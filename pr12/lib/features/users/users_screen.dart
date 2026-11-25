import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../settings/settings_model.dart';
import '../settings/settings_screen.dart';

import 'new_user_screen.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users — Practice 12'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Reload',
            onPressed: () => context.read<UsersModel>().load(),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'New user',
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const NewUserScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer2<UsersModel, SettingsModel>(
        builder: (context, model, settings, _) {
          if (model.loading && model.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (model.error != null && model.items.isEmpty) {
            return _buildError(model);
          }

          // Filter users by the selected city.
          final filteredUsers = settings.city == null
              ? model.items
              : model.items
                    .where((user) => user.address.city == settings.city)
                    .toList();

          return Column(
            children: [
              // Show a banner only for cached data.
              if (model.fromCache)
                MaterialBanner(
                  content: const Text('Saved data · no connection'),
                  leading: const Icon(Icons.wifi_off),
                  actions: [
                    TextButton(
                      onPressed: model.load,
                      child: const Text('Retry'),
                    ),
                  ],
                ),

              if (settings.city != null)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_city),
                  title: Text('City: ${settings.city}'),
                  trailing: IconButton(
                    tooltip: 'Clear filter',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      settings.setCity(null);
                    },
                  ),
                ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: model.load,
                  child: filteredUsers.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 180),
                            Center(child: Text('No users found')),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filteredUsers.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];

                            return ListTile(
                              title: Text(user.name),
                              subtitle: Text(
                                '${user.email}\n'
                                '${user.address.city}',
                              ),
                              isThreeLine: true,
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        UserDetailScreen(user: user),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildError(UsersModel model) {
    final error = model.error;

    return switch (error) {
      NoConnectionException() => _Message(
        title: 'Offline',
        subtitle: 'No internet connection and no saved users.',
        onRetry: model.load,
      ),
      NotFoundException() => const _Message(
        title: 'Not found',
        subtitle: 'The requested resource was not found.',
      ),
      UnauthorizedException() => const _Message(
        title: 'Unauthorized',
        subtitle: 'Access to this resource is denied.',
      ),
      ServerException(:final status) => _Message(
        title: 'Server error $status',
        subtitle: 'The server could not complete the request.',
        onRetry: model.load,
      ),
      BadResponseException() => const _Message(
        title: 'Bad response',
        subtitle: 'The server returned unexpected data.',
      ),
      _ => _Message(
        title: 'Error',
        subtitle: 'Could not load users.',
        onRetry: model.load,
      ),
    };
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.title, required this.subtitle, this.onRetry});

  final String title;
  final String subtitle;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}
