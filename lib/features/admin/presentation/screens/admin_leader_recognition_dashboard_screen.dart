import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class AdminLeaderRecognitionDashboardScreen extends ConsumerWidget {
  const AdminLeaderRecognitionDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.leaderRecognitionDashboard),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Quarterly Recognition Eligibility',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildEligibilityCard(
            'Conference Discounts',
            'Leaders who submitted all reports',
            Icons.confirmation_num,
          ),
          _buildEligibilityCard(
            'Kingdom Heirs Swag',
            'Leaders with highest completion rates',
            Icons.checkroom,
          ),
          _buildEligibilityCard(
            'Free Books',
            'Leaders who raised future leaders',
            Icons.menu_book,
          ),
          _buildEligibilityCard(
            'School of Ministry Scholarships',
            'Leaders who launched new groups',
            Icons.school,
          ),
          _buildEligibilityCard(
            'Leadership Recognition Awards',
            'Top performers',
            Icons.emoji_events,
          ),
          const SizedBox(height: 32),
          const Text(
            'Top Leaders',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildLeaderRow(
            'John Doe',
            'Kingdom Multiplier',
            '28 Groups',
            'Trainer',
          ),
          _buildLeaderRow(
            'Sarah Smith',
            'Kingdom Builder',
            '12 Groups',
            'Group Leader',
          ),
          _buildLeaderRow('Samuel O.', 'Gold Leader', '5 Groups', 'Trainer'),
          _buildLeaderRow(
            'David K.',
            'Silver Leader',
            '3 Groups',
            'Group Leader',
          ),
        ],
      ),
    );
  }

  Widget _buildEligibilityCard(String title, String criteria, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.info),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Eligible: $criteria'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // View eligible leaders list
        },
      ),
    );
  }

  Widget _buildLeaderRow(
    String name,
    String badge,
    String groups,
    String cert,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(name[0])),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Badge: $badge • $groups'),
        trailing:
            Chip(label: Text(cert), backgroundColor: AppColors.goldContainer),
      ),
    );
  }
}
