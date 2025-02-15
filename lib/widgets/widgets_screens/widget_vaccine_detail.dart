import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WidgetVaccineDetail extends StatelessWidget {
  final Map<String, dynamic> record;

  const WidgetVaccineDetail({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailItem(l10n?.vaccineName ?? 'Vaccine Name', record['vaccine']),
          _buildDetailItem(l10n?.vaccineDate ?? 'Date Received', record['date']),
          _buildDetailItem(l10n?.vaccineDose ?? 'Dose Sequence', record['dose']),
          _buildDetailItem(l10n?.vaccinePlace ?? 'Place Given', record['place']),
          if (record['remarks']?.isNotEmpty == true) _buildDetailItem(l10n?.vaccineRemark ?? 'Remark', record['remarks']),
          if (record['image'] != null) ...[
            const SizedBox(height: 24),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  base64Decode(record['image']!),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? 'N/A',
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
