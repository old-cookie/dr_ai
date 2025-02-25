import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../models/medical_certificate_model.dart';
import '../../widgets_units/widget_button.dart';
import '../../../screens/medical_certificate/screen_add_medical_certificate.dart';

/// 醫療證明書記錄列表元件
class WidgetMedicalCertificateRecord extends StatelessWidget {
  final List<MedicalCertificateModel> certificates;
  final Function(MedicalCertificateModel) onDeleteCertificate;
  final Function(MedicalCertificateModel) onViewCertificate;

const WidgetMedicalCertificateRecord({
    super.key,
    required this.certificates,
    required this.onViewCertificate,
    required this.onDeleteCertificate,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            localizations.medicalCertificates,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        
        certificates.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    localizations.noCertificatesFound,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: certificates.length,
                itemBuilder: (context, index) {
                  final certificate = certificates[index];
                  return _buildCertificateItem(context, certificate, localizations);
                },
              ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: widgetButton(
            localizations.addMedicalCertificate,
            Icons.add,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScreenAddMedicalCertificate(),
                ),
              ).then((_) {
                (context as Element).markNeedsBuild();
              });
            },
            context: context,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildCertificateItem(
    BuildContext context,
    MedicalCertificateModel certificate,
    AppLocalizations localizations,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          certificate.hospital,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('${localizations.certificateNumber}: ${certificate.certificateNumber}'),
            const SizedBox(height: 4),
            Text('${localizations.treatmentDate}: ${certificate.treatmentDate}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.visibility),
              onPressed: () => onViewCertificate(certificate),
              tooltip: localizations.viewCertificate,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDeleteCertificate(certificate),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}
