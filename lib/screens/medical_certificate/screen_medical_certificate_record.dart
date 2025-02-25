import 'package:flutter/material.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'dart:convert';
import 'screen_add_medical_certificate.dart';
import 'screen_medical_certificate_detail.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../widgets/widgets_units/widget_button.dart';

class ScreenMedicalCertificateRecord extends StatefulWidget {
  const ScreenMedicalCertificateRecord({super.key});

  @override
  ScreenMedicalCertificateRecordState createState() =>
      ScreenMedicalCertificateRecordState();
}

class ScreenMedicalCertificateRecordState extends State<ScreenMedicalCertificateRecord> {
  List<Map<String, dynamic>> certificates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = EncryptedSharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      final certificateKeys =
          allKeys.where((key) => key.startsWith('medical_certificate_')).toList();

      List<Map<String, dynamic>> loadedCertificates = [];
      for (String key in certificateKeys) {
        final data = prefs.getString(key);
        if (data != null && data.isNotEmpty) {
          final Map<String, dynamic> certificate =
              Map<String, dynamic>.from(jsonDecode(data));
          certificate['id'] = key;
          loadedCertificates.add(certificate);
        }
      }

      loadedCertificates
          .sort((a, b) => b['id'].toString().compareTo(a['id'].toString()));

      setState(() {
        certificates = loadedCertificates;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _deleteCertificate(String id) async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    
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
      final prefs = EncryptedSharedPreferences.getInstance();
      await prefs.remove(id);
      _loadCertificates();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      // 如果沒有本地化資源，顯示基本界面
      return Scaffold(
        appBar: AppBar(
          title: const Text("Medical Certificate Records"),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.certificateNumber),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
                  ))
                : certificates.isEmpty
                    ? Center(
                        child: Text(l10n.noRecordsFound),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: certificates.length,
                        itemBuilder: (context, index) {
                          final certificate = certificates[index];
                          return Card(
                            child: ListTile(
                              title: Text(certificate['certificateNumber'] ?? 'No Number'),
                              subtitle: Text(
                                '${certificate['hospital'] ?? 'Unknown Hospital'} - ${certificate['treatmentDate'] ?? 'No Date'}',
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ScreenMedicalCertificateDetail(
                                      certificate: certificate,
                                      onDelete: () => _deleteCertificate(certificate['id']),
                                    ),
                                  ),
                                ).then((_) => _loadCertificates());
                              },
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: widgetButton(
              l10n.addMedicalCertificate,
              Icons.add,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScreenAddMedicalCertificate(),
                  ),
                ).then((_) => _loadCertificates());
              },
              context: context,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
