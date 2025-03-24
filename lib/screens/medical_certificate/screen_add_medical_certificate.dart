import 'package:flutter/material.dart';
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
import '../../widgets/widgets_screens/medical_certificate/widget_add_medical_certificate.dart';

/// 醫療證明添加螢幕
/// 
/// 此螢幕允許用戶添加新的醫療證明記錄，包含以下功能：
/// - 表單輸入醫療證明詳細資訊
/// - 通過相機、相冊或文檔掃描器獲取證明照片
/// - 使用OCR自動識別並填充表單數據
/// - 保存醫療證明記錄到加密的本地存儲
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

  // 表單控制器和狀態變數
  final TextEditingController certificateNumberController = TextEditingController(); // 證明編號控制器
  final TextEditingController remarksController = TextEditingController(); // 備註控制器
  String? selectedHospital; // 選擇的醫院
  String? treatmentDate; // 治療日期
  String? hospitalizationStartDate; // 住院開始日期
  String? hospitalizationEndDate; // 住院結束日期
  String? sickLeaveStartDate; // 病假開始日期
  String? sickLeaveEndDate; // 病假結束日期
  String? followUpDate; // 複診日期

  // 圖片處理相關變數
  final ImagePicker _picker = ImagePicker(); // 圖片選擇器
  String? _base64Image; // Base64編碼的圖片
  Uint8List? _imageBytes; // 圖片位元組資料
  bool _isLoading = false; // 加載狀態標誌
  bool _isSaving = false; // 保存狀態標誌
  bool _isProcessingOcr = false; // OCR處理狀態標誌

  @override
  void initState() {
    super.initState();
    selectedHospital = hospitalsList.first; // 初始化默認選擇第一個醫院
  }


  /// 顯示圖片來源選擇選單
  /// 
  /// 呈現三個選項：
  /// - 掃描文檔
  /// - 使用相機拍照
  /// - 從相冊選擇圖片
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

  /// 從相機拍攝圖片
  /// 
  /// 請求相機權限並啟動相機進行拍照，然後處理拍攝的照片
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

  /// 從相冊選擇圖片
  /// 
  /// 請求相冊權限並開啟相冊選擇器，然後處理選擇的照片
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

  /// 使用文檔掃描器
  /// 
  /// 啟動文檔掃描器掃描文件，提供更高精度的文本識別
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

  /// 處理圖片並進行OCR識別
  /// 
  /// 1. 將圖片轉換為黑白以提高OCR識別率
  /// 2. 執行OCR文字識別
  /// 3. 解析識別結果並填充表單欄位
  /// 
  /// @param bytes 圖片的二進位資料
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
      _isProcessingOcr = true;
    });

    // 執行OCR處理
    try {
      // 舊有的OCR服務
  //    final recognizedText = await OcrService.recognizeText(bwBytes);
  //    final extractedData = OcrService.parseMedicalCertificate(recognizedText);
      // 直接執行Demo的OCR服務
      final extractedData = await OcrService.processImage(bwBytes);
      setState(() {

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

  /// 顯示圖片選擇選項
  /// 
  /// 觸發底部彈出選單，顯示可用的圖片獲取方式
  Future<void> _pickImage() async {
    _showImageSourceOptions();
  }

  /// 儲存醫療證明記錄
  /// 
  /// 將表單數據保存到加密的本地存儲並返回上一個頁面
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

    // 使用醫療證明表單小部件構建UI
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
