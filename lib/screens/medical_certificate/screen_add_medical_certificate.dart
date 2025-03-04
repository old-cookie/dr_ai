import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';  // 添加權限處理器
import '../../services/ocr_service.dart';
import '../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../widgets/widgets_units/widget_button.dart';
import '../../widgets/widgets_units/widget_title.dart';
import '../../widgets/widgets_screens/medical_certificate/widget_add_medical_certificate.dart';

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
  bool _isProcessingOcr = false; // 新增OCR處理狀態
  String _ocrResultText = ''; // 新增OCR結果文本

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

  // 顯示圖片來源選擇選單
  void _showImageSourceOptions() {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.document_scanner),
                title: Text(l10n.scanAndFill),
                onTap: () {
                  Navigator.of(context).pop();
                  _scanDocument();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(l10n.takeImage),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(l10n.uploadImage),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImageFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 從相機拍攝圖片
  Future<void> _getImageFromCamera() async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    setState(() => _isLoading = true);
    
    try {
      // 檢查相機權限
      var cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.cameraPermissionDenied)),
          );
          setState(() => _isLoading = false);
          return;
        }
      }

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (photo != null) {
        await _processImage(await photo.readAsBytes());
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 從相冊選擇圖片
  Future<void> _getImageFromGallery() async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    setState(() => _isLoading = true);
    
    try {
      // 檢查相冊權限
      var galleryStatus = await Permission.photos.status;
      if (!galleryStatus.isGranted) {
        galleryStatus = await Permission.photos.request();
        if (!galleryStatus.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Photo library permission denied')),
          );
          setState(() => _isLoading = false);
          return;
        }
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (image != null) {
        await _processImage(await image.readAsBytes());
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 使用文檔掃描器
  Future<void> _scanDocument() async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    setState(() => _isLoading = true);
    try {
      // 請求相機權限
      var cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.cameraPermissionDenied)),
          );
          setState(() => _isLoading = false);
          return;
        }
      }

      // 使用cunning_document_scanner掃描文檔
      List<String> pictures = [];
      try {
        pictures = await CunningDocumentScanner.getPictures() ?? [];
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.scannerError}: $e')),
        );
        setState(() => _isLoading = false);
        return;
      }

      if (pictures.isNotEmpty) {
        // 讀取第一張掃描的圖片
        final File imageFile = File(pictures[0]);
        await _processImage(await imageFile.readAsBytes());
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 處理圖片並進行OCR
  Future<void> _processImage(Uint8List bytes) async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    
    // 將圖片轉換為黑白
    final img.Image? originalImage = img.decodeImage(bytes);
    if (originalImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.imageFormat)),
      );
      return;
    }
    
    // 轉換為黑白圖片
    final img.Image bwImage = img.grayscale(originalImage);
    final Uint8List bwBytes = Uint8List.fromList(img.encodeJpg(bwImage, quality: 90));

    setState(() {
      _imageBytes = bwBytes;
      _base64Image = base64Encode(bwBytes);
      _isProcessingOcr = true; // 開始OCR處理
      _ocrResultText = '';
    });

    // 執行OCR處理
    try {
      final recognizedText = await OcrService.recognizeText(bwBytes);
      final extractedData = OcrService.parseMedicalCertificate(recognizedText);

      setState(() {
        _ocrResultText = recognizedText;

        // 填入OCR識別結果
        if (certificateNumberController.text.isEmpty && 
            extractedData.containsKey('certificateNumber')) {
          certificateNumberController.text = extractedData['certificateNumber'];
        }

        if (extractedData.containsKey('hospital')) {
          final hospital = extractedData['hospital'];
          final hospitalIndex = hospitalsList
              .indexWhere((h) => h.toLowerCase().contains(hospital.toLowerCase()));
          
          if (hospitalIndex != -1 && selectedHospital == hospitalsList.first) {
            selectedHospital = hospitalsList[hospitalIndex];
          }
        }

        if (treatmentDate == null && extractedData.containsKey('treatmentDate')) {
          treatmentDate = extractedData['treatmentDate'];
        }

        if (hospitalizationStartDate == null && 
            extractedData.containsKey('hospitalizationStartDate')) {
          hospitalizationStartDate = extractedData['hospitalizationStartDate'];
        }

        if (hospitalizationEndDate == null && 
            extractedData.containsKey('hospitalizationEndDate')) {
          hospitalizationEndDate = extractedData['hospitalizationEndDate'];
        }

        if (sickLeaveStartDate == null && 
            extractedData.containsKey('sickLeaveStartDate')) {
          sickLeaveStartDate = extractedData['sickLeaveStartDate'];
        }

        if (sickLeaveEndDate == null && 
            extractedData.containsKey('sickLeaveEndDate')) {
          sickLeaveEndDate = extractedData['sickLeaveEndDate'];
        }

        if (followUpDate == null && extractedData.containsKey('followUpDate')) {
          followUpDate = extractedData['followUpDate'];
        }

        if (remarksController.text.isEmpty && extractedData.containsKey('remarks')) {
          remarksController.text = extractedData['remarks'];
        }
      });
      
      // 顯示OCR處理結果
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(extractedData.isNotEmpty 
              ? l10n.ocrSuccessful 
              : l10n.ocrNoDataFound),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.ocrError}: $e')),
      );
    } finally {
      setState(() => _isProcessingOcr = false);
    }
  }

  // 替換原先的_pickImage方法，改為顯示選擇選單
  Future<void> _pickImage() async {
    _showImageSourceOptions();
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

    // 使用新的醫療證明表單小部件
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addMedicalCertificate),
      ),
      body: WidgetAddMedicalCertificate(
        certificateNumberController: certificateNumberController,
        selectedHospital: selectedHospital,
        treatmentDate: treatmentDate,
        hospitalizationStartDate: hospitalizationStartDate,
        hospitalizationEndDate: hospitalizationEndDate,
        sickLeaveStartDate: sickLeaveStartDate,
        sickLeaveEndDate: sickLeaveEndDate,
        followUpDate: followUpDate,
        remarksController: remarksController,
        imageBytes: _imageBytes,
        isProcessingOcr: _isProcessingOcr, // 傳遞OCR處理狀態
        onHospitalChanged: (value) {
          setState(() {
            selectedHospital = value;
          });
        },
        onTreatmentDateSelect: (date) {
          setState(() {
            treatmentDate = date;
          });
        },
        onHospitalizationStartDateSelect: (date) {
          setState(() {
            hospitalizationStartDate = date;
          });
        },
        onHospitalizationEndDateSelect: (date) {
          setState(() {
            hospitalizationEndDate = date;
          });
        },
        onSickLeaveStartDateSelect: (date) {
          setState(() {
            sickLeaveStartDate = date;
          });
        },
        onSickLeaveEndDateSelect: (date) {
          setState(() {
            sickLeaveEndDate = date;
          });
        },
        onFollowUpDateSelect: (date) {
          setState(() {
            followUpDate = date;
          });
        },
        onUploadImage: _isLoading || _isProcessingOcr ? null : _pickImage,
        onSave: _isSaving ? null : _saveRecord,
        onAddVaccine: () {
          // 導覽到疫苗記錄頁面
          Navigator.pushNamed(context, '/vaccine/add');
        },
      ),
    );
  }
}
