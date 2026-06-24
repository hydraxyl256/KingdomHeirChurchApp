import 'package:equatable/equatable.dart';

enum BadgeType {
  bronze,
  silver,
  gold,
  builder,
  multiplier;

  String get displayName => switch (this) {
        BadgeType.bronze => 'Bronze Leader (1 Group)',
        BadgeType.silver => 'Silver Leader (3 Groups)',
        BadgeType.gold => 'Gold Leader (5 Groups)',
        BadgeType.builder => 'Kingdom Builder (10 Groups)',
        BadgeType.multiplier => 'Kingdom Multiplier (25+ Groups)',
      };
}

class LeaderBadge extends Equatable {
  const LeaderBadge({
    required this.id,
    required this.userId,
    required this.type,
    required this.awardedAt,
  });

  final String id;
  final String userId;
  final BadgeType type;
  final DateTime awardedAt;

  @override
  List<Object?> get props => [id, userId, type, awardedAt];
}
