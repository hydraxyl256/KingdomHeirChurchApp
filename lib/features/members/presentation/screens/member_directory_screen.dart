import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/widgets/app_avatar.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class MemberDirectoryScreen extends StatefulWidget {
  const MemberDirectoryScreen({super.key});

  @override
  State<MemberDirectoryScreen> createState() => _MemberDirectoryScreenState();
}

class _MemberDirectoryScreenState extends State<MemberDirectoryScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  final _members = [
    {
      'name': 'David Steward',
      'role': 'Group Leader',
      'ministry': 'Young Adults',
    },
    {'name': 'Sarah Mensah', 'role': 'Pastor', 'ministry': "Women's Ministry"},
    {'name': 'James Osei', 'role': 'Senior Pastor', 'ministry': 'Leadership'},
    {'name': 'Abena Adjei', 'role': 'Member', 'ministry': 'Worship Team'},
    {'name': 'Michael Asante', 'role': 'Volunteer', 'ministry': 'Media & Tech'},
    {
      'name': 'Grace Nkrumah',
      'role': 'Member',
      'ministry': "Children's Ministry",
    },
    {'name': 'Emmanuel Yaw', 'role': 'Bishop', 'ministry': 'Leadership'},
    {'name': 'Akosua Boateng', 'role': 'Member', 'ministry': 'Prayer Team'},
  ];

  List<Map<String, String>> get _filtered => _members
      .where(
        (m) =>
            m['name']!.toLowerCase().contains(_query.toLowerCase()) ||
            m['ministry']!.toLowerCase().contains(_query.toLowerCase()),
      )
      .toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.memberDirectory),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchMembers,
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _filtered.length,
        itemBuilder: (context, i) {
          final m = _filtered[i];
          return ListTile(
            leading: AppAvatar(name: m['name']),
            title: Text(m['name']!),
            subtitle: Text('${m['role']} · ${m['ministry']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.message_outlined),
                  onPressed: () {},
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              ],
            ),
            onTap: () => context.go('/home/members/$i'),
          ).animate().fadeIn(delay: Duration(milliseconds: i * 50));
        },
      ),
    );
  }
}
