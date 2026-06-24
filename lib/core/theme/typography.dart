/// Kingdom Heir — Typography System (canonical entry point)
///
/// Inter powers UI/body copy. Playfair Display powers display headings and
/// brand voice. The full Material 3 type-role table lives in
/// [AppTypography.textTheme]; convenience styles (scripture ref, quote,
/// ticket code, stat number) live alongside it.
///
/// This file re-exports [AppTypography] so callers can `import
/// 'package:kingdom_heir/core/theme/typography.dart';`.
library kingdom_heir.theme.typography;

import 'package:kingdom_heir/core/theme/app_typography.dart' show AppTypography;
import 'package:kingdom_heir/core/theme/theme.dart' show AppTypography;
import 'package:kingdom_heir/core/theme/typography.dart' show AppTypography;

export 'app_typography.dart' show AppTypography;
