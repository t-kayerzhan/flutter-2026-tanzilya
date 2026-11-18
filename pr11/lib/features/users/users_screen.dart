import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'new_user_screen.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users — real API'),
        actions: [
          IconButton(
            tooltip: 'Reload',
            onPressed: () => context.read<UsersModel>().load(),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'New user',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const NewUserScreen()),
            ),
            icon: const Icon(Icons.person_add),
          ),
        ],
      ),
      body: Consumer<UsersModel>(
        builder: (context, model, _) {
          if (model.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return switch (model.error) {
            null => RefreshIndicator(
              onRefresh: model.load,
              child: model.items.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 180),
                        Center(child: Text('No users yet')),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: model.items.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final user = model.items[index];
                        return ListTile(
                          title: Text(user.name),
                          subtitle: Text('${user.email}\n${user.address.city}'),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => UserDetailScreen(user: user),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            NoConnectionException() => _Message(
              title: 'Offline',
              subtitle: 'Could not connect. Please try again.',
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
          };
        },
      ),
    );
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
