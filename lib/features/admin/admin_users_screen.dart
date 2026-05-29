import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../services/admin_service.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/status_badge.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: usersAsync.when(
        loading: () => const LoadingWidget(message: 'Loading users...'),
        error: (error, stackTrace) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(adminUsersProvider),
        ),
        data: (users) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                child: ListTile(
                  title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(user.email),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'E', style: const TextStyle(color: Colors.white)),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) => _handleAction(context, ref, user.userId, value),
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'activate', child: Text('Activate')),
                      PopupMenuItem(value: 'suspend', child: Text('Suspend')),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemCount: users.length,
          );
        },
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, WidgetRef ref, int userId, String action) async {
    try {
      if (action == 'activate') {
        await ref.read(adminServiceProvider).activateUser(userId);
      } else if (action == 'suspend') {
        await ref.read(adminServiceProvider).suspendUser(userId);
      }
      ref.invalidate(adminUsersProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User ${action == 'activate' ? 'activated' : 'suspended'}')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Action failed: $error')));
      }
    }
  }
}