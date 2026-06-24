import 'package:equatable/equatable.dart';

enum CertificateType {
  completion,
  commissioning,
  groupLeader,
  trainer,
  regionalLeader;

  String get displayName => switch (this) {
        CertificateType.completion => 'Certificate of Completion',
        CertificateType.commissioning =>
          'Certificate of Completion & Commissioning',
        CertificateType.groupLeader => 'Group Leader Certificate',
        CertificateType.trainer => 'Trainer Certificate',
        CertificateType.regionalLeader => 'Regional Leader Commission',
      };
}

class Certificate extends Equatable {
  const Certificate({
    required this.id,
    required this.userId,
    required this.type,
    required this.issuedAt,
    this.issuedBy,
    this.metadata = const {},
  });

  final String id;
  final String userId;
  final CertificateType type;
  final DateTime issuedAt;
  final String? issuedBy;
  final Map<String, dynamic> metadata;

  @override
  List<Object?> get props => [id, userId, type, issuedAt, issuedBy, metadata];
}
