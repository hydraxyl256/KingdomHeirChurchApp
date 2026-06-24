import 'package:equatable/equatable.dart';

class CovenantSignature extends Equatable {
  const CovenantSignature({
    required this.id,
    required this.userId,
    required this.applicationId,
    required this.signatureText,
    required this.ipAddress,
    required this.signedAt,
  });

  final String id;
  final String userId;
  final String applicationId;
  final String signatureText;
  final String ipAddress;
  final DateTime signedAt;

  @override
  List<Object?> get props => [
        id,
        userId,
        applicationId,
        signatureText,
        ipAddress,
        signedAt,
      ];
}
