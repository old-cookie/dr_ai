import 'package:flutter/material.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'dart:convert';
import 'screen_add_medical_certificate.dart';
import 'screen_medical_certificate_detail.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/widgets_units/widget_button.dart';

class ScreenMedicalCertificateRecord extends StatefulWidget {
  const ScreenMedicalCertificateRecord({super.key});

  @override
  ScreenMedicalCertificateRecordState createState() => ScreenMedicalCertificateRecordState();
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
      final certificateKeys = allKeys.where((key) => key.startsWith('medical_certificate_')).toList();

      List<Map<String, dynamic>> loadedCertificates = [];
      for (String key in certificateKeys) {
        final data = prefs.getString(key);
        if (data != null && data.isNotEmpty) {
          try {
            final Map<String, dynamic> certificate = Map<String, dynamic>.from(jsonDecode(data));
            certificate['id'] = key;
            loadedCertificates.add(certificate);
          } catch (e) {
            debugPrint('Error parsing JSON for key $key: $e');
          }
        }
      }

      loadedCertificates.sort((a, b) => b['id'].toString().compareTo(a['id'].toString()));

      setState(() {
        certificates = loadedCertificates;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading certificates: $e');
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

  // 編輯醫療證明記錄
  void _editCertificate(Map<String, dynamic> certificate) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScreenAddMedicalCertificate(
          recordToEdit: certificate,
          recordKey: certificate['id'],
        ),
      ),
    ).then((_) {
      _loadCertificates();
    });
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
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
                            return Dismissible(
                              key: Key(certificate['id']),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (direction) async {
                                return await showDialog<bool>(
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
                              },
                              onDismissed: (direction) {
                                _deleteCertificate(certificate['id']);
                              },
                              child: Card(
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                child: InkWell(
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    certificate['hospital'] ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text('${l10n.certificateNumber}: ${certificate['certificateNumber'] ?? ''}'),
                                                  const SizedBox(height: 4),
                                                  Text('${l10n.treatmentDate}: ${certificate['treatmentDate'] ?? ''}'),
                                                ],
                                              ),
                                            ),
                                            if (certificate['image'] != null) ...[
                                              const SizedBox(width: 12),
                                              SizedBox(
                                                width: 100,
                                                height: 100,
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Image.memory(
                                                    base64Decode(certificate['image']),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        Divider(height: 20),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            OutlinedButton.icon(
                                              icon: const Icon(Icons.edit, size: 18),
                                              label: Text(l10n.edit),
                                              onPressed: () => _editCertificate(certificate),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
      ),
    );
  }
}
