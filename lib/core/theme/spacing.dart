/// Kingdom Heir — Spacing System (canonical entry point)
///
/// Production 8-point grid. All margins, paddings, and gaps should resolve
/// to one of the [AppSpacing] tokens.
///
/// This file is the canonical entry point as requested by the design-system
/// spec. It re-exports [AppSpacing] from `app_spacing.dart` so the rest of
/// the codebase continues to compile unchanged.
library kingdom_heir.theme.spacing;

import 'package:kingdom_heir/core/theme/app_spacing.dart' show AppSpacing;
import 'package:kingdom_heir/core/theme/spacing.dart' show AppSpacing;
import 'package:kingdom_heir/core/theme/theme.dart' show AppSpacing;

export 'app_spacing.dart' show AppSpacing;
