import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a product application submitted by a user awaiting admin review.
class ProductApplication {
  const ProductApplication({
    required this.id,
    required this.userId,
    required this.userFullName,
    required this.userEmail,
    required this.productType,
    required this.status,
    required this.submittedAt,
    this.assignedAdminId,
    this.assignedAdminName,
    this.reviewedAt,
    this.reviewedBy,
    this.internalNotes,
    this.rejectionReason,
    this.requestedDocuments,
    this.uploadedDocuments,
    this.applicationData,
  });

  final String id;
  final String userId;
  final String userFullName;
  final String userEmail;
  final ProductType productType;
  final ApplicationStatus status;
  final DateTime submittedAt;
  final String? assignedAdminId;
  final String? assignedAdminName;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? internalNotes;
  final String? rejectionReason;
  final List<String>? requestedDocuments;
  final List<String>? uploadedDocuments;
  final Map<String, dynamic>? applicationData;

  factory ProductApplication.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductApplication(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userFullName: data['userFullName'] as String? ?? 'Unknown',
      userEmail: data['userEmail'] as String? ?? '',
      productType: ProductType.fromString(data['productType'] as String? ?? ''),
      status: ApplicationStatus.fromString(data['status'] as String? ?? ''),
      submittedAt:
          (data['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      assignedAdminId: data['assignedAdminId'] as String?,
      assignedAdminName: data['assignedAdminName'] as String?,
      reviewedAt: (data['reviewedAt'] as Timestamp?)?.toDate(),
      reviewedBy: data['reviewedBy'] as String?,
      internalNotes: data['internalNotes'] as String?,
      rejectionReason: data['rejectionReason'] as String?,
      requestedDocuments: (data['requestedDocuments'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      uploadedDocuments: (data['uploadedDocuments'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      applicationData: data['applicationData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userFullName': userFullName,
      'userEmail': userEmail,
      'productType': productType.value,
      'status': status.value,
      'submittedAt': Timestamp.fromDate(submittedAt),
      if (assignedAdminId != null) 'assignedAdminId': assignedAdminId,
      if (assignedAdminName != null) 'assignedAdminName': assignedAdminName,
      if (reviewedAt != null) 'reviewedAt': Timestamp.fromDate(reviewedAt!),
      if (reviewedBy != null) 'reviewedBy': reviewedBy,
      if (internalNotes != null) 'internalNotes': internalNotes,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      if (requestedDocuments != null)
        'requestedDocuments': requestedDocuments,
      if (uploadedDocuments != null) 'uploadedDocuments': uploadedDocuments,
      if (applicationData != null) 'applicationData': applicationData,
    };
  }
}

enum ProductType {
  savings('savings', 'Savings Account'),
  current('current', 'Current Account'),
  loan('loan', 'Personal Loan'),
  creditCard('creditCard', 'Credit Card'),
  timeDeposit('timeDeposit', 'Time Deposit'),
  insurance('insurance', 'Insurance'),
  investment('investment', 'Investment'),
  unknown('unknown', 'Unknown Product');

  const ProductType(this.value, this.displayName);
  final String value;
  final String displayName;

  static ProductType fromString(String value) {
    return ProductType.values.firstWhere(
      (p) => p.value == value,
      orElse: () => ProductType.unknown,
    );
  }
}

enum ApplicationStatus {
  pending('pending', 'Pending'),
  underReview('underReview', 'Under Review'),
  approved('approved', 'Approved'),
  rejected('rejected', 'Rejected'),
  moreInfoRequired('moreInfoRequired', 'More Info Required');

  const ApplicationStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static ApplicationStatus fromString(String value) {
    return ApplicationStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => ApplicationStatus.pending,
    );
  }
}
