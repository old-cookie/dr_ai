import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../models/medical_certificate_model.dart';

/// 醫療證明書詳情元件
class WidgetMedicalCertificateDetail extends StatelessWidget {
  final MedicalCertificateModel certificate;

const WidgetMedicalCertificateDetail({
    super.key,
    required this.certificate,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 醫院名稱和證明書編號
          Text(
            certificate.hospital,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            '${localizations.certificateNumber}: ${certificate.certificateNumber}',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          const SizedBox(height: 24),
          
          // 各項日期資訊
          _buildInfoItem(localizations.treatmentDate, certificate.treatmentDate),
          
          if (certificate.hospitalizationStartDate != null && certificate.hospitalizationEndDate != null)
            _buildDateRangeItem(
              localizations.hospitalizationPeriod, 
              certificate.hospitalizationStartDate!,
              certificate.hospitalizationEndDate!,
            ),
          
          if (certificate.sickLeaveStartDate != null && certificate.sickLeaveEndDate != null)
            _buildDateRangeItem(
              localizations.sickLeavePeriod, 
              certificate.sickLeaveStartDate!,
              certificate.sickLeaveEndDate!,
            ),
          
          if (certificate.followUpDate != null)
            _buildInfoItem(localizations.followUpDate, certificate.followUpDate!),
          
          // 備註
          if (certificate.remarks != null && certificate.remarks!.isNotEmpty)
            _buildInfoItem(localizations.remarks, certificate.remarks!),
          
          const SizedBox(height: 24),
          
          // 證明書圖片
          if (certificate.imageBytes != null) ...[
            Text(
              localizations.certificateImage,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.memory(
                certificate.imageBytes!,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildDateRangeItem(String label, String startDate, String endDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            '$startDate 至 $endDate',
            style: TextStyle(fontSize: 16),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
