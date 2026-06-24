import 'package:flutter/material.dart';

/// Adaptive layout that switches between compact and expanded layouts.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.compact,
    super.key,
    this.medium,
    this.expanded,
  });

  /// Layout for phones (< 600dp)
  final Widget compact;

  /// Layout for small tablets / landscape phones (600–840dp).
  final Widget? medium;

  /// Layout for tablets / iPads (> 840dp).
  final Widget? expanded;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width >= 840 && expanded != null) return expanded!;
        if (width >= 600 && medium != null) return medium!;
        return compact;
      },
    );
  }
}
