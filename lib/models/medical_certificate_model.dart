import 'dart:typed_data';

/// 醫療證明書資料模型
class MedicalCertificateModel {
  final String id;
  final String certificateNumber;
  final String hospital;
  final String treatmentDate;
  final String? hospitalizationStartDate;
  final String? hospitalizationEndDate;
  final String? sickLeaveStartDate;
  final String? sickLeaveEndDate;
  final String? followUpDate;
  final String? remarks;
  final Uint8List? imageBytes;
  final DateTime createdAt;

  MedicalCertificateModel({
    required this.id,
    required this.certificateNumber,
    required this.hospital,
    required this.treatmentDate,
    this.hospitalizationStartDate,
    this.hospitalizationEndDate,
    this.sickLeaveStartDate,
    this.sickLeaveEndDate,
    this.followUpDate,
    this.remarks,
    this.imageBytes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 從JSON映射創建醫療證明書模型
  factory MedicalCertificateModel.fromJson(Map<String, dynamic> json) {
    return MedicalCertificateModel(
      id: json['id'] as String,
      certificateNumber: json['certificateNumber'] as String,
      hospital: json['hospital'] as String,
      treatmentDate: json['treatmentDate'] as String,
      hospitalizationStartDate: json['hospitalizationStartDate'] as String?,
      hospitalizationEndDate: json['hospitalizationEndDate'] as String?,
      sickLeaveStartDate: json['sickLeaveStartDate'] as String?,
      sickLeaveEndDate: json['sickLeaveEndDate'] as String?,
      followUpDate: json['followUpDate'] as String?,
      remarks: json['remarks'] as String?,
      imageBytes: json['imageBytes'] != null 
          ? Uint8List.fromList(List<int>.from(json['imageBytes']))
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// 轉換為JSON映射
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'certificateNumber': certificateNumber,
      'hospital': hospital,
      'treatmentDate': treatmentDate,
      'hospitalizationStartDate': hospitalizationStartDate,
      'hospitalizationEndDate': hospitalizationEndDate,
      'sickLeaveStartDate': sickLeaveStartDate,
      'sickLeaveEndDate': sickLeaveEndDate,
      'followUpDate': followUpDate,
      'remarks': remarks,
      'imageBytes': imageBytes?.toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 複製醫療證明書模型並更新特定屬性
  MedicalCertificateModel copyWith({
    String? id,
    String? certificateNumber,
    String? hospital,
    String? treatmentDate,
    String? hospitalizationStartDate,
    String? hospitalizationEndDate,
    String? sickLeaveStartDate,
    String? sickLeaveEndDate,
    String? followUpDate,
    String? remarks,
    Uint8List? imageBytes,
    DateTime? createdAt,
  }) {
    return MedicalCertificateModel(
      id: id ?? this.id,
      certificateNumber: certificateNumber ?? this.certificateNumber,
      hospital: hospital ?? this.hospital,
      treatmentDate: treatmentDate ?? this.treatmentDate,
      hospitalizationStartDate: hospitalizationStartDate ?? this.hospitalizationStartDate,
      hospitalizationEndDate: hospitalizationEndDate ?? this.hospitalizationEndDate,
      sickLeaveStartDate: sickLeaveStartDate ?? this.sickLeaveStartDate,
      sickLeaveEndDate: sickLeaveEndDate ?? this.sickLeaveEndDate,
      followUpDate: followUpDate ?? this.followUpDate,
      remarks: remarks ?? this.remarks,
      imageBytes: imageBytes ?? this.imageBytes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
