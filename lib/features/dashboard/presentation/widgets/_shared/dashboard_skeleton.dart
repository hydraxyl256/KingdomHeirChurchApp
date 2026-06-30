// Kingdom Heir — Dashboard Skeleton (loading placeholder)
//
// Mirrors the 10-section layout of the redesigned dashboard so the
// dashboard screen never collapses to a blank container while data
// loads. Each section uses `AppShimmerBox` to keep the bones in sync
// with the existing design tokens.

import 'package:flutter/material.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/widgets/app_empty_state.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      children: [
        // Header
        Row(
          children: [
            AppShimmerBox(width: 64, height: 64, borderRadius: 32),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppShimmerBox(width: 96, height: 12),
                  SizedBox(height: 8),
                  AppShimmerBox(width: 160, height: 22),
                  SizedBox(height: 8),
                  AppShimmerBox(width: 220, height: 12),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xl),

        // Scripture hero
        AppShimmerBox(width: double.infinity, height: 220, borderRadius: 20),
        SizedBox(height: AppSpacing.xl),

        // Section title
        AppShimmerBox(width: 180, height: 18),
        SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 160,
          child: Row(
            children: [
              Expanded(
                child: AppShimmerBox(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 14,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppShimmerBox(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 14,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppShimmerBox(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 14,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.xl),

        // Service card
        AppShimmerBox(width: double.infinity, height: 120, borderRadius: 14),
        SizedBox(height: AppSpacing.xl),

        // Daily journey
        AppShimmerBox(width: double.infinity, height: 220, borderRadius: 14),
        SizedBox(height: AppSpacing.xl),

        // Church today
        AppShimmerBox(width: double.infinity, height: 180, borderRadius: 14),
        SizedBox(height: AppSpacing.xl),

        // Prayer corner
        AppShimmerBox(width: double.infinity, height: 160, borderRadius: 14),
        SizedBox(height: AppSpacing.xl),

        // Community
        SizedBox(
          height: 120,
          child: Row(
            children: [
              Expanded(
                child: AppShimmerBox(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 14,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppShimmerBox(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 14,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.xl),

        // Quick actions
        SizedBox(
          height: 100,
          child: Row(
            children: [
              Expanded(
                child: AppShimmerBox(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 12,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppShimmerBox(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 12,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppShimmerBox(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 12,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppShimmerBox(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}