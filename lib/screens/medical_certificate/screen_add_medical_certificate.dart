import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../../services/screen_crop_image.dart';
import '../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../widgets/widgets_units/widget_button.dart';
import '../../widgets/widgets_units/widget_title.dart';

class ScreenAddMedicalCertificate extends StatefulWidget {
  const ScreenAddMedicalCertificate({super.key});

  @override
  State<ScreenAddMedicalCertificate> createState() => _ScreenAddMedicalCertificateState();
}

class _ScreenAddMedicalCertificateState extends State<ScreenAddMedicalCertificate> {
  // 醫院列表
  final List<String> hospitalsList = [
    'Queen Mary Hospital',
    'Prince of Wales Hospital',
    'Queen Elizabeth Hospital',
    'Tuen Mun Hospital',
    'United Christian Hospital',
    'Princess Margaret Hospital',
    'Kwong Wah Hospital',
    'Caritas Medical Centre',
    'Pamela Youde Nethersole Eastern Hospital',
    'Ruttonjee Hospital',
    'Hong Kong Baptist Hospital',
    'St. Teresa\'s Hospital',
    'Hong Kong Sanatorium & Hospital',
    'Matilda International Hospital',
    'Other',
  ];

  // 控制器和狀態變數
  final TextEditingController certificateNumberController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  String? selectedHospital;
  String? treatmentDate;
  String? hospitalizationStartDate;
  String? hospitalizationEndDate;
  String? sickLeaveStartDate;
  String? sickLeaveEndDate;
  String? followUpDate;

  final ImagePicker _picker = ImagePicker();
  String? _base64Image;
  Uint8List? _imageBytes;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    selectedHospital = hospitalsList.first;
  }

  // 日期選擇器
  Future<void> _selectDate(BuildContext context, Function(String) onDateSelected) async {
    final DateTime? pickedDate = await showOmniDateTimePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      is24HourMode: true,
      isShowSeconds: false,
      minutesInterval: 1,
      secondsInterval: 1,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      constraints: const BoxConstraints(
        maxWidth: 350,
        maxHeight: 650,
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1.drive(
            Tween(
              begin: 0,
              end: 1,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
    );

    if (pickedDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      onDateSelected(formattedDate);
    }
  }

  // 圖片選擇與處理
  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    setState(() => _isLoading = true);
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final decodedImage = img.decodeImage(bytes);
        if (decodedImage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.imageFormat)),
          );
          return;
        }

        final croppedBytes = await Navigator.push<Uint8List>(
          context,
          MaterialPageRoute(
            builder: (context) => ScreenCropImage(imageBytes: bytes),
          ),
        );

        if (croppedBytes != null) {
          setState(() {
            _imageBytes = croppedBytes;
            _base64Image = base64Encode(croppedBytes);
          });
        }
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 儲存記錄
  Future<void> _saveRecord() async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    // 驗證必填欄位
    if (certificateNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterCertificateNumber)),
      );
      return;
    }

    if (treatmentDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectTreatmentDate)),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final prefs = EncryptedSharedPreferences.getInstance();

      Map<String, dynamic> recordMap = {
        'certificateNumber': certificateNumberController.text,
        'hospital': selectedHospital,
        'treatmentDate': treatmentDate,
        'hospitalizationStartDate': hospitalizationStartDate,
        'hospitalizationEndDate': hospitalizationEndDate,
        'sickLeaveStartDate': sickLeaveStartDate,
        'sickLeaveEndDate': sickLeaveEndDate,
        'followUpDate': followUpDate,
        'remarks': remarksController.text,
        'image': _base64Image,
      };

      await prefs.setString('medical_certificate_${DateTime.now().millisecondsSinceEpoch}', jsonEncode(recordMap));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recordSaved)),
      );

      Navigator.pop(context);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      // 如果沒有本地化資源，顯示基本界面
      return Scaffold(
        appBar: AppBar(
          title: const Text("Add Medical Certificate"),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addMedicalCertificate),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: certificateNumberController,
              decoration: InputDecoration(
                labelText: l10n.certificateNumber,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: selectedHospital,
              items: hospitalsList.map((hospital) {
                return DropdownMenuItem<String>(
                  value: hospital,
                  child: Text(hospital),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedHospital = value;
                });
              },
              decoration: InputDecoration(
                labelText: l10n.hospital,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            widgetTitle(l10n.treatmentDate, top: 0, bottom: 8),
            widgetButton(
              l10n.selectDate,
              Icons.calendar_today,
              () => _selectDate(context, (date) {
                setState(() {
                  treatmentDate = date;
                });
              }),
              context: context,
              color: Theme.of(context).colorScheme.primary,
            ),
            if (treatmentDate != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Selected Date: $treatmentDate',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widgetTitle(l10n.hospitalizationStartDate, top: 0, bottom: 8),
                      widgetButton(
                        l10n.selectDate,
                        Icons.calendar_today,
                        () => _selectDate(context, (date) {
                          setState(() {
                            hospitalizationStartDate = date;
                          });
                        }),
                        context: context,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      if (hospitalizationStartDate != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Selected Date: $hospitalizationStartDate',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widgetTitle(l10n.hospitalizationEndDate, top: 0, bottom: 8),
                      widgetButton(
                        l10n.selectDate,
                        Icons.calendar_today,
                        () => _selectDate(context, (date) {
                          setState(() {
                            hospitalizationEndDate = date;
                          });
                        }),
                        context: context,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      if (hospitalizationEndDate != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Selected Date: $hospitalizationEndDate',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            widgetTitle(l10n.sickLeaveStartDate, top: 0, bottom: 8),
            widgetButton(
              l10n.selectDate,
              Icons.calendar_today,
              () => _selectDate(context, (date) {
                setState(() {
                  sickLeaveStartDate = date;
                });
              }),
              context: context,
              color: Theme.of(context).colorScheme.primary,
            ),
            if (sickLeaveStartDate != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Selected Date: $sickLeaveStartDate',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            widgetTitle(l10n.sickLeaveEndDate, top: 0, bottom: 8),
            widgetButton(
              l10n.selectDate,
              Icons.calendar_today,
              () => _selectDate(context, (date) {
                setState(() {
                  sickLeaveEndDate = date;
                });
              }),
              context: context,
              color: Theme.of(context).colorScheme.primary,
            ),
            if (sickLeaveEndDate != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Selected Date: $sickLeaveEndDate',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            widgetTitle(l10n.followUpDate, top: 0, bottom: 8),
            widgetButton(
              l10n.selectDate,
              Icons.calendar_today,
              () => _selectDate(context, (date) {
                setState(() {
                  followUpDate = date;
                });
              }),
              context: context,
              color: Theme.of(context).colorScheme.primary,
            ),
            if (followUpDate != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Selected Date: $followUpDate',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: remarksController,
              decoration: InputDecoration(
                labelText: l10n.remarks,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16.0),
            if (_imageBytes != null) Image.memory(_imageBytes!),
            const SizedBox(height: 16.0),
            widgetButton(
              l10n.selectImage,
              Icons.image,
              _isLoading ? null : _pickImage,
              context: context,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16.0),
            const SizedBox(height: 16),
            widgetButton(
              l10n.saveRecord,
              Icons.save,
              _isSaving ? null : _saveRecord,
              context: context,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
