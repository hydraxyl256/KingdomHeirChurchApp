import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';


class AdminTranslationManagerScreen extends ConsumerStatefulWidget {
  const AdminTranslationManagerScreen({super.key});

  @override
  ConsumerState<AdminTranslationManagerScreen> createState() =>
      _AdminTranslationManagerScreenState();
}

class _AdminTranslationManagerScreenState
    extends ConsumerState<AdminTranslationManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _workflowStages = [
    'Draft',
    'Review',
    'Approved',
    'Published',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _workflowStages.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Translation Manager'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: _workflowStages.map((stage) => Tab(text: stage)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _workflowStages.map((stage) {
          return _TranslationList(status: stage.toLowerCase());
        }).toList(),
      ),
    );
  }
}

class _TranslationList extends ConsumerWidget {
  const _TranslationList({required this.status});
  final String status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a full implementation, this would fetch from a combined view of all pending translations.
    // For now, we simulate the UI of pending translations.
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3, // Mock data
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              'Mock Translation Item ${index + 1}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text('Type: Sermon • Language: French (fr)'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4,),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _getStatusColor(status)),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: _buildActionButtons(status),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.grey;
      case 'review':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'published':
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  Widget _buildActionButtons(String status) {
    switch (status) {
      case 'draft':
        return ElevatedButton(
          onPressed: () {},
          child: const Text('Submit for Review'),
        );
      case 'review':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
              onPressed: () {},
              child: const Text('Reject'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Approve'),
            ),
          ],
        );
      case 'approved':
        return ElevatedButton(
          onPressed: () {},
          child: const Text('Publish'),
        );
      case 'published':
        return OutlinedButton(
          onPressed: () {},
          child: const Text('Unpublish'),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
