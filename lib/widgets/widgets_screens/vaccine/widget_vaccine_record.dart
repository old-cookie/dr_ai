import 'package:flutter/material.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'dart:convert';
import '../../../screens/vaccine/screen_add_vaccine_record.dart';
import '../../widgets_units/widget_button.dart';
import '../../../screens/vaccine/screen_vaccine_detail.dart';
import '../../../l10n/app_localizations.dart';

class WidgetVaccineRecord extends StatefulWidget {
  const WidgetVaccineRecord({super.key});

  @override
  State<WidgetVaccineRecord> createState() => _WidgetVaccineRecordState();
}

class _WidgetVaccineRecordState extends State<WidgetVaccineRecord> {
  Future<void> _deleteRecord(int index, List<String> submissions) async {
    final prefs = EncryptedSharedPreferences.getInstance();
    submissions.removeAt(index);
    await prefs.setStringList('submissions', submissions);
    setState(() {});
  }

  Future<List<String>> _loadSubmissions() async {
    final prefs = EncryptedSharedPreferences.getInstance();
    return prefs.getStringList('submissions') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _loadSubmissions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text(l10n?.errorLoadingRecords ?? 'Error loading records.'));
                } else if (snapshot.data!.isEmpty) {
                  return Center(child: Text(l10n?.noRecordsFound ?? 'No records found.'));
                } else {
                  final submissions = snapshot.data!;
                  return ListView.builder(
                    itemCount: submissions.length,
                    itemBuilder: (context, index) {
                      final recordMap = jsonDecode(submissions[index]) as Map<String, dynamic>;
                      return Dismissible(
                        key: Key(submissions[index]),
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
                              title: Text(l10n?.deleteRecord ?? 'Delete Record'),
                              content: Text(l10n?.deleteConfirm ?? 'Are you sure you want to delete this record?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: Text(l10n?.cancel ?? 'Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: Text(l10n?.delete ?? 'Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) {
                          _deleteRecord(index, submissions);
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ScreenVaccineDetail(record: recordMap),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${recordMap['vaccine']}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(l10n?.vaccineFieldDate(recordMap['date']) ?? 'Date: ${recordMap['date']}'),
                                        Text(l10n?.vaccineFieldDose(recordMap['dose']) ?? 'Dose: ${recordMap['dose']}'),
                                        Text(l10n?.vaccineFieldPlace(recordMap['place']) ?? 'Place: ${recordMap['place']}'),
                                        if (recordMap['remarks']?.isNotEmpty == true) ...[
                                          const SizedBox(height: 4),
                                          Text(l10n?.vaccineFieldRemarks(recordMap['remarks']) ?? 'Remarks: ${recordMap['remarks']}'),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (recordMap['image'] != null) ...[
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(
                                          base64Decode(recordMap['image']!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: widgetButton(
              l10n?.vaccineAddTitle ?? 'Add Vaccination Record',
              Icons.add,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScreenAddVaccineRecord(),
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
      ),
    );
  }
}
