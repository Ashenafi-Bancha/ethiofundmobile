import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_widget.dart';

class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  ConsumerState<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen> {
  String _selectedType = 'summary';

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(adminReportsProvider(_selectedType));

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'summary', label: Text('Summary')),
                ButtonSegment(value: 'monthly', label: Text('Monthly')),
                ButtonSegment(value: 'yearly', label: Text('Yearly')),
              ],
              selected: {_selectedType},
              onSelectionChanged: (selection) => setState(() => _selectedType = selection.first),
            ),
          ),
          Expanded(
            child: reportsAsync.when(
              loading: () => const LoadingWidget(message: 'Loading reports...'),
              error: (error, stackTrace) => AppErrorWidget(
                message: error.toString(),
                onRetry: () => ref.invalidate(adminReportsProvider(_selectedType)),
              ),
              data: (reports) {
                if (reports.isEmpty) {
                  return const Center(child: Text('No reports available.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return Card(
                      child: ListTile(
                        title: Text(report['title']?.toString() ?? 'Report', style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(report['description']?.toString() ?? report.toString()),
                        leading: const Icon(Icons.description_outlined, color: AppColors.primary),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemCount: reports.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}