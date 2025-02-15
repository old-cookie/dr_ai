import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import '../../widgets/widgets_units/widget_button.dart';
import '../../widgets/widgets_units/widget_title.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'screen_crop_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ScreenAddVaccineRecord extends StatefulWidget {
  const ScreenAddVaccineRecord({super.key});

  @override
  State<ScreenAddVaccineRecord> createState() => _ScreenAddVaccineRecordState();
}

class _ScreenAddVaccineRecordState extends State<ScreenAddVaccineRecord> {
  final List<String> listOfItem = [
    'COVID-19 vaccine',
    'Hepatitis A vaccine',
    'Hepatitis B vaccine',
    'Herpes Zoster vaccine',
    'HPV 9-Valent vaccine',
    'Influenza Seasonal vaccine',
  ];

  final List<String> secondListOfItem = [
    '1st',
    '2nd',
    '3rd',
  ];
  final List<String> thirdListOfItem = [
    'Department of Health/Hospital Authority',
    'Elderly Home',
    'Private Clinic/Hospital',
    'School',
  ];

  String? selectedVaccine;
  String? selectedDose;
  String? selectedPlace;
  String? selectedDate;
  final TextEditingController remarkController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _base64Image;
  Uint8List? _imageBytes;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    selectedVaccine = listOfItem.first;
    selectedDose = secondListOfItem.first;
    selectedPlace = thirdListOfItem.first;
  }

  Future<void> _pickImage() async {
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
            SnackBar(content: Text(AppLocalizations.of(context)?.imageFormat ?? 'Only PNG or JPG images supported')),
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

  void _saveRecord() async {
    setState(() => _isSaving = true);
    try {
      String selectedVaccine = this.selectedVaccine ?? listOfItem.first;
      String selectedDose = this.selectedDose ?? secondListOfItem.first;
      String selectedPlace = this.selectedPlace ?? thirdListOfItem.first;
      String remarks = remarkController.text;

      final prefs = EncryptedSharedPreferences.getInstance();

      final l10n = AppLocalizations.of(context);
      Map<String, dynamic> recordMap = {
        'date': selectedDate ?? (l10n?.notSelected ?? 'Not selected'),
        'vaccine': selectedVaccine,
        'dose': selectedDose,
        'place': selectedPlace,
        'remarks': remarks,
        'image': _base64Image,
      };

      String record = jsonEncode(recordMap);

      final submissions = prefs.getStringList('submissions') ?? [];

      submissions.add(record);

      await prefs.setStringList('submissions', submissions);

      Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _openDatePicker(BuildContext context) async {
    final DateTime? dateTime = await showOmniDateTimePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
      is24HourMode: false,
      isForce2Digits: true,
      minutesInterval: 1,
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

    if (dateTime != null) {
      setState(() {
        selectedDate = '${dateTime.month}/${dateTime.day}/${dateTime.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      children: [
        Scaffold(
            appBar: AppBar(
              title: Text(l10n?.vaccineAddTitle ?? 'Add Vaccination Record'),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: ListView(
                children: <Widget>[
                  const SizedBox(height: 16),
                  widgetTitle(l10n?.vaccineName ?? 'Vaccine Name', top: 0, bottom: 8),
                  DropdownSearch<String>(
                    selectedItem: selectedVaccine ?? listOfItem.first,
                    items: (filter, props) => listOfItem,
                    onChanged: (value) {
                      setState(() {
                        selectedVaccine = value;
                      });
                    },
                    decoratorProps: DropDownDecoratorProps(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                    ),
                    popupProps: PopupProps.menu(
                      fit: FlexFit.loose,
                      constraints: BoxConstraints(),
                      searchDelay: Duration(milliseconds: 0),
                      showSearchBox: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  widgetTitle(l10n?.vaccineDose ?? 'Dose Sequence', top: 0, bottom: 8),
                  DropdownSearch<String>(
                    selectedItem: selectedDose ?? secondListOfItem.first,
                    items: (filter, props) => secondListOfItem,
                    onChanged: (value) {
                      setState(() {
                        selectedDose = value;
                      });
                    },
                    decoratorProps: DropDownDecoratorProps(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                    ),
                    popupProps: PopupProps.menu(
                      fit: FlexFit.loose,
                      constraints: BoxConstraints(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  widgetTitle(l10n?.vaccineDate ?? 'Date Received', top: 0, bottom: 8),
                  ElevatedButton(
                    onPressed: () => _openDatePicker(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(l10n?.selectDate ?? 'Select Date'),
                  ),
                  if (selectedDate != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Selected Date: $selectedDate',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  widgetTitle(l10n?.vaccinePlace ?? 'Place Given (Optional)', top: 0, bottom: 8),
                  DropdownSearch<String>(
                    selectedItem: selectedPlace ?? thirdListOfItem.first,
                    items: (filter, props) => thirdListOfItem,
                    onChanged: (value) {
                      setState(() {
                        selectedPlace = value;
                      });
                    },
                    decoratorProps: DropDownDecoratorProps(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                    ),
                    popupProps: PopupProps.menu(
                      fit: FlexFit.loose,
                      constraints: BoxConstraints(),
                      searchDelay: Duration(milliseconds: 0),
                      showSearchBox: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  widgetTitle(l10n?.vaccineRemark ?? 'Remark (Optional)', top: 0, bottom: 8),
                  TextField(
                    controller: remarkController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Other information',
                    ),
                  ),
                  const SizedBox(height: 16),
                  widgetTitle(l10n?.vaccinePhoto ?? 'Vaccination Record Photo (Optional)', top: 0, bottom: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_library),
                          label: Text(l10n?.pickImage ?? 'Pick Image'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_imageBytes != null) ...[
                    const SizedBox(height: 8),
                    LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        final decodedImage = img.decodeImage(_imageBytes!);
                        if (decodedImage == null) return const SizedBox();

                        final maxWidth = constraints.maxWidth;
                        final imageWidth = decodedImage.width.toDouble();
                        final imageHeight = decodedImage.height.toDouble();
                        final aspectRatio = imageWidth / imageHeight;

                        final displayWidth = imageWidth > maxWidth ? maxWidth : imageWidth;
                        final displayHeight = displayWidth / aspectRatio;

                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              _imageBytes!,
                              width: displayWidth,
                              height: displayHeight,
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  widgetButton(
                    l10n?.saveRecord ?? 'Save',
                    Icons.save,
                    _saveRecord,
                    context: context,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            )),
        if (_isLoading || _isSaving) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
