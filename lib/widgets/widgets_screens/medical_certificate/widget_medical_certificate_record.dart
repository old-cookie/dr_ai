import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets_units/widget_button.dart';
import '../../../screens/medical_certificate/screen_add_medical_certificate.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'dart:convert';

/// 醫療證明書記錄列表元件
class WidgetMedicalCertificateRecord extends StatefulWidget {
  const WidgetMedicalCertificateRecord({super.key});

  @override
  State<WidgetMedicalCertificateRecord> createState() => _WidgetMedicalCertificateRecordState();
}

class _WidgetMedicalCertificateRecordState extends State<WidgetMedicalCertificateRecord> {
  late EncryptedSharedPreferences prefs;
  List<MapEntry<String, Map<String, dynamic>>> _certificates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCertificates();
  }

  // 加載所有醫療證明記錄
  Future<void> _loadCertificates() async {
    setState(() {
      _isLoading = true;
    });

    try {
      prefs = EncryptedSharedPreferences.getInstance();
      final allKeys = await prefs.getKeys();
      
      // 篩選醫療證明記錄的鍵
      final certificateKeys = allKeys.where((key) => key.startsWith('medical_certificate_')).toList();
      
      // 獲取並解析所有醫療證明記錄
      _certificates = [];
      for (final key in certificateKeys) {
        final jsonString = await prefs.getString(key);
        if (jsonString != null) {
          try {
            final Map<String, dynamic> data = jsonDecode(jsonString);
            _certificates.add(MapEntry(key, data));
          } catch (e) {
            debugPrint('Error parsing JSON for key $key: $e');
          }
        }
      }
      
      // 根據日期排序，最新的在前面
      _certificates.sort((a, b) {
        final dateA = a.value['treatmentDate'] ?? '';
        final dateB = b.value['treatmentDate'] ?? '';
        return dateB.compareTo(dateA);
      });
    } catch (e) {
      debugPrint('Error loading certificates: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 刪除醫療證明記錄
  Future<void> _deleteCertificate(String recordKey) async {
    try {
      await prefs.remove(recordKey);
      await _loadCertificates();
    } catch (e) {
      debugPrint('Error deleting certificate: $e');
    }
  }

  // 查看醫療證明詳情
  void _viewCertificate(Map<String, dynamic> certificate) {
    // 可以添加查看詳情的功能
  }

  // 編輯醫療證明記錄
  void _editCertificate(String recordKey, Map<String, dynamic> certificate) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScreenAddMedicalCertificate(
          recordToEdit: certificate,
          recordKey: recordKey,
        ),
      ),
    ).then((_) {
      setState(() {});
      _loadCertificates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              localizations.medicalCertificates,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          _certificates.isEmpty
              ? Expanded(
                  child: Center(
                    child: Text(
                      localizations.noCertificatesFound,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: _certificates.length,
                    itemBuilder: (context, index) {
                      final entry = _certificates[index];
                      final recordKey = entry.key;
                      final certificate = entry.value;
                      return Dismissible(
                        key: Key(recordKey),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(localizations.deleteRecord),
                              content: Text(localizations.deleteConfirm),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: Text(localizations.cancel),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: Text(localizations.delete),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) {
                          _deleteCertificate(recordKey);
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: InkWell(
                            onTap: () => _viewCertificate(certificate),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
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
                                            Text('${localizations.certificateNumber}: ${certificate['certificateNumber'] ?? ''}'),
                                            const SizedBox(height: 4),
                                            Text('${localizations.treatmentDate}: ${certificate['treatmentDate'] ?? ''}'),
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
                                        label: Text(localizations.edit),
                                        onPressed: () => _editCertificate(recordKey, certificate),
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
              localizations.addMedicalCertificate,
              Icons.add,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScreenAddMedicalCertificate(),
                  ),
                ).then((_) {
                  setState(() {});
                  _loadCertificates();
                });
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
