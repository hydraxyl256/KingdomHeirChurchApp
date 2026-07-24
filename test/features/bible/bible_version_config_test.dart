import 'package:flutter_test/flutter_test.dart';
import 'package:kingdom_heir/features/bible/domain/entities/bible_version_config.dart';

void main() {
  group('BibleVersionConfig', () {
    test('uses a licensed default instead of YouVersion Bible ID 1', () {
      expect(BibleVersionConfig.fallbackVersionId(), 3034);
      expect(BibleVersionConfig.fallbackVersionId(), isNot(1));
    });

    test('normalizes an old persisted Bible ID 1 to the licensed fallback', () {
      expect(BibleVersionConfig.normalizeVersionId(1), 3034);
    });

    test('does not allow an unlicensed fallback override', () {
      expect(
        BibleVersionConfig.fallbackVersionId(
          overrides: const [3034, 12],
          override: 1,
        ),
        3034,
      );
    });

    test('keeps a requested licensed version and orders it first', () {
      final candidates = BibleVersionConfig.orderedCandidates(
        12,
        overrides: const [3034, 12],
        fallbackOverride: 3034,
      );
      expect(candidates.first, 12);
      expect(candidates, containsAllInOrder([12, 3034]));
    });
  });
}
