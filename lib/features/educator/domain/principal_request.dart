enum PrincipalRequestStatus {
  pending,
  approved,
  rejected,
}

class PrincipalRequest {
  PrincipalRequest({
    required this.id,
    required this.educatorId,
    required this.requestedAt,
    required this.status,
    this.reviewedAt,
    this.reviewerAdminId,
  });

  final String id;
  final String educatorId;
  final DateTime requestedAt;
  final PrincipalRequestStatus status;
  final DateTime? reviewedAt;
  final String? reviewerAdminId;
}

