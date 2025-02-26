import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../widgets_units/widget_button.dart';
import '../../widgets_units/widget_title.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../../../l10n/app_localizations.dart';

/// 新增疫苗接種記錄的Widget元件
class WidgetAddVaccineRecord extends StatelessWidget {
  final String? selectedVaccine;
  final String? selectedDose;
  final String? selectedPlace;
  final String? selectedDate;
  final TextEditingController remarkController;
  final Uint8List? imageBytes;
  final Function() pickImage;
  final Function(String?) onVaccineChanged;
  final Function(String?) onDoseChanged;
  final Function(String?) onPlaceChanged;
  final Function() onDateSelect;
  final Function() onSave;
  final List<String> listOfItem;
  final List<String> secondListOfItem;
  final List<String> thirdListOfItem;
  final bool isLoading;
  final bool isSaving;

  const WidgetAddVaccineRecord({
    super.key,
    required this.selectedVaccine,
    required this.selectedDose,
    required this.selectedPlace,
    required this.selectedDate,
    required this.remarkController,
    required this.imageBytes,
    required this.pickImage,
    required this.onVaccineChanged,
    required this.onDoseChanged,
    required this.onPlaceChanged,
    required this.onDateSelect,
    required this.onSave,
    required this.listOfItem,
    required this.secondListOfItem,
    required this.thirdListOfItem,
    required this.isLoading,
    required this.isSaving,
  });

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

                  // First Dropdown for Vaccine Selection
                  widgetTitle(l10n?.vaccineName ?? 'Vaccine Name', top: 0, bottom: 8),
                  DropdownSearch<String>(
                    selectedItem: selectedVaccine ?? listOfItem.first,
                    items: (filter, props) => listOfItem,
                    onChanged: onVaccineChanged,
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

                  // Second Dropdown for Dose Sequence
                  widgetTitle(l10n?.vaccineDose ?? 'Dose Sequence', top: 0, bottom: 8),
                  DropdownSearch<String>(
                    selectedItem: selectedDose ?? secondListOfItem.first,
                    items: (filter, props) => secondListOfItem,
                    onChanged: onDoseChanged,
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

                  // Date Picker Section
                  widgetTitle(l10n?.vaccineDate ?? 'Date Received', top: 0, bottom: 8),
                  ElevatedButton(
                    onPressed: onDateSelect,
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

                  // Third Dropdown for Place Given
                  widgetTitle(l10n?.vaccinePlace ?? 'Place Given (Optional)', top: 0, bottom: 8),
                  DropdownSearch<String>(
                    selectedItem: selectedPlace ?? thirdListOfItem.first,
                    items: (filter, props) => thirdListOfItem,
                    onChanged: onPlaceChanged,
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

                  // Remark Section
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

                  // Add Image Upload Section
                  widgetTitle(l10n?.vaccinePhoto ?? 'Vaccination Record Photo (Optional)', top: 0, bottom: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: pickImage,
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

                  if (imageBytes != null) ...[
                    const SizedBox(height: 8),
                    LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        final decodedImage = img.decodeImage(imageBytes!);
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
                              imageBytes!,
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

                  // Save Button
                  widgetButton(
                    l10n?.saveRecord ?? 'Save',
                    Icons.save,
                    onSave,
                    context: context,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            )),
        if (isLoading || isSaving) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
