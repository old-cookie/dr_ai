import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'dart:convert';

class ScreenMedicalCertificateDetail extends StatelessWidget {
  final Map<String, dynamic> certificate;
  final VoidCallback onDelete;

  const ScreenMedicalCertificateDetail({
    super.key,
    required this.certificate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Medical Certificate Detail"),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final String base64Image = certificate['image'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.certificateNumber),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.deleteRecord),
                  content: Text(l10n.deleteConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(l10n.delete),
                    ),
                  ],
                ),
              );

              if (confirmDelete == true) {
                onDelete();
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DetailRow(
                      label: l10n.certificateNumber,
                      value: certificate['certificateNumber'] ?? '',
                    ),
                    DetailRow(
                      label: l10n.hospital,
                      value: certificate['hospital'] ?? '',
                    ),
                    DetailRow(
                      label: l10n.treatmentDate,
                      value: certificate['treatmentDate'] ?? '',
                    ),
                    if (certificate['hospitalizationStartDate'] != null && certificate['hospitalizationStartDate'].isNotEmpty)
                      DetailRow(
                        label: l10n.hospitalizationStartDate,
                        value: certificate['hospitalizationStartDate'],
                      ),
                    if (certificate['hospitalizationEndDate'] != null && certificate['hospitalizationEndDate'].isNotEmpty)
                      DetailRow(
                        label: l10n.hospitalizationEndDate,
                        value: certificate['hospitalizationEndDate'],
                      ),
                    if (certificate['sickLeaveStartDate'] != null && certificate['sickLeaveStartDate'].isNotEmpty)
                      DetailRow(
                        label: l10n.sickLeaveStartDate,
                        value: certificate['sickLeaveStartDate'],
                      ),
                    if (certificate['sickLeaveEndDate'] != null && certificate['sickLeaveEndDate'].isNotEmpty)
                      DetailRow(
                        label: l10n.sickLeaveEndDate,
                        value: certificate['sickLeaveEndDate'],
                      ),
                    if (certificate['followUpDate'] != null && certificate['followUpDate'].isNotEmpty)
                      DetailRow(
                        label: l10n.followUpDate,
                        value: certificate['followUpDate'],
                      ),
                    if (certificate['remarks'] != null && certificate['remarks'].isNotEmpty)
                      DetailRow(
                        label: l10n.remarks,
                        value: certificate['remarks'],
                      ),
                  ],
                ),
              ),
            ),
            if (base64Image.isNotEmpty) ...[
              const SizedBox(height: 16.0),
              Center(
                child: Image.memory(
                  base64Decode(base64Image),
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.0,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
