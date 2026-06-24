import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/features/admin/data/repositories/admin_members_repository.dart';
import 'package:kingdom_heir/features/auth/domain/entities/app_user.dart';

final adminMembersProvider =
    FutureProvider.autoDispose<List<AppUser>>((ref) async {
  final repo = ref.watch(adminMembersRepositoryProvider);
  final response = await repo.getMembers();

  return (response as List<dynamic>).map((json) {
    final map = json as Map<String, dynamic>;

    // Parse role safely
    UserRole? role;
    if (map['role'] != null) {
      final roleStr = map['role'] as String;
      role = UserRole.values.firstWhere(
        (r) => r.name == roleStr,
        orElse: () => UserRole.member,
      );
    }

    return AppUser(
      id: map['id'] as String,
      email: map['email'] as String? ?? 'No Email',
      fullName: map['full_name'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      role: role,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }).toList();
});

class AdminMembersScreen extends ConsumerWidget {
  const AdminMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(adminMembersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(adminMembersProvider),
          ),
        ],
      ),
      body: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Error loading members: $err')),
        data: (members) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Joined')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: members.map((member) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: member.avatarUrl != null
                                  ? NetworkImage(member.avatarUrl!)
                                  : null,
                              child: member.avatarUrl == null
                                  ? Text(member.displayName[0].toUpperCase())
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Text(member.displayName),
                          ],
                        ),
                      ),
                      DataCell(Text(member.email)),
                      DataCell(
                        Chip(
                          label: Text(member.role?.displayName ?? 'Member'),
                          backgroundColor: _getRoleColor(
                              context, member.role?.name ?? 'member',),
                        ),
                      ),
                      const DataCell(
                        Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                        ),
                      ),
                      DataCell(Text(member.createdAt
                              ?.toLocal()
                              .toString()
                              .split(' ')[0] ??
                          'Unknown',),),
                      DataCell(
                        PopupMenuButton<String>(
                          onSelected: (action) {
                            if (action == 'edit_role') {
                              _showRoleEditor(context, ref, member);
                            } else if (action == 'deactivate') {
                              _confirmSuspend(context, ref, member);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit_role',
                              child: Text('Edit Role'),
                            ),
                            const PopupMenuItem(
                              value: 'deactivate',
                              child: Text('Suspend (Soft Delete)'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getRoleColor(BuildContext context, String role) {
    if (role == 'admin' || role == 'pastor' || role == 'bishop') {
      return Theme.of(context).colorScheme.primaryContainer;
    }
    if (role == 'group_leader' || role == 'deacon') {
      return Theme.of(context).colorScheme.secondaryContainer;
    }
    return Theme.of(context).colorScheme.surfaceContainerHighest;
  }

  void _showRoleEditor(BuildContext context, WidgetRef ref, AppUser member) {
    showDialog<void>(
      context: context,
      builder: (context) {
        var selectedRole = member.role?.name ?? 'member';

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Role: ${member.displayName}'),
              content: DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(value: 'USER', child: Text('Member')),
                  DropdownMenuItem(
                      value: 'MODERATOR', child: Text('Moderator'),),
                  DropdownMenuItem(value: 'ADMIN', child: Text('Admin')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => selectedRole = val);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      final repo = ref.read(adminMembersRepositoryProvider);
                      await repo.updateRole(member.id, selectedRole);
                      ref.invalidate(adminMembersProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Role updated successfully'),),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error updating role: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmSuspend(BuildContext context, WidgetRef ref, AppUser member) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend User'),
        content: Text(
            'Are you sure you want to suspend ${member.displayName}? They will be soft-deleted and unable to access the app.',),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,),
            onPressed: () async {
              Navigator.pop(context);
              try {
                final repo = ref.read(adminMembersRepositoryProvider);
                await repo.suspendUser(member.id);
                ref.invalidate(adminMembersProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User suspended')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error suspending: $e')),
                  );
                }
              }
            },
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }
}
