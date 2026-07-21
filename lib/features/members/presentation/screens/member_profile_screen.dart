import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/widgets/app_avatar.dart';
import 'package:kingdom_heir/core/widgets/app_button.dart';

class MemberProfileScreen extends StatelessWidget {
  const MemberProfileScreen({required this.memberId, super.key});
  final String memberId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(child: SizedBox.shrink()),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  children: [
                    const AppAvatar(
                      name: 'David Steward',
                      size: 80,
                      borderColor: Colors.white,
                      borderWidth: 3,
                    ).animate().fadeIn(),
                    const SizedBox(height: AppSpacing.md),
                    Text('David Steward', style: theme.textTheme.headlineSmall)
                        .animate()
                        .fadeIn(delay: 100.ms),
                    Text(
                      'Group Leader · Young Professionals',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppButton(
                          label: 'Message',
                          icon: Icons.message_rounded,
                          width: 140,
                          onPressed: () {},
                        ),
                        const SizedBox(width: AppSpacing.md),
                        AppButton(
                          label: 'Pray',
                          icon: Icons.self_improvement_rounded,
                          width: 140,
                          variant: AppButtonVariant.outlined,
                          onPressed: () {},
                        ),
                      ],
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: AppSpacing.xl),
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),
                    const _InfoTile(
                      icon: Icons.email_outlined,
                      label: 'david.steward@email.com',
                    ),
                    const _InfoTile(
                      icon: Icons.phone_outlined,
                      label: '+1 (555) 234-5678',
                    ),
                    const _InfoTile(
                      icon: Icons.location_on_outlined,
                      label: 'Atlanta, GA',
                    ),
                    const _InfoTile(
                      icon: Icons.groups_rounded,
                      label: 'Young Professionals Group',
                    ),
                    const _InfoTile(
                      icon: Icons.volunteer_activism_rounded,
                      label: 'Worship Team Volunteer',
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('About', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Passionate about faith and entrepreneurship. Leading the Young Professionals group since 2024. Loves worship and community building.',
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}
