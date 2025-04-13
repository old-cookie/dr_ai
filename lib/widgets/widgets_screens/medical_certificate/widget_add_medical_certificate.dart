import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

import 'dart:typed_data';
import '../../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class DateSelector extends StatelessWidget {
  final String label;
  final String? value;
  final Function(String) onDateSelected;

  const DateSelector({
    super.key,
    required this.label,
    this.value,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: value != null ? DateFormat('yyyy-MM-dd').parse(value!) : DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );

        if (picked != null) {
          onDateSelected(DateFormat('yyyy-MM-dd').format(picked));
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value ?? localizations.selectDate),
            const Icon(Icons.calendar_month),
          ],
        ),
      ),
    );
  }
}

/// 新增醫療證明書記錄的Widget元件
class WidgetAddMedicalCertificate extends StatelessWidget {
  // 必要的參數
  final TextEditingController certificateNumberController;
  final String? selectedHospital;
  final String? treatmentDate;
  final String? hospitalizationStartDate;
  final String? hospitalizationEndDate;
  final String? sickLeaveStartDate;
  final String? sickLeaveEndDate;
  final String? followUpDate;
  final TextEditingController remarksController;
  final Uint8List? imageBytes;
  final bool isProcessingOcr; // 新增OCR處理狀態參數

  // 各種事件回調函數
  final Function(String?) onHospitalChanged;
  final Function(String) onTreatmentDateSelect;
  final Function(String) onHospitalizationStartDateSelect;
  final Function(String) onHospitalizationEndDateSelect;
  final Function(String) onSickLeaveStartDateSelect;
  final Function(String) onSickLeaveEndDateSelect;
  final Function(String) onFollowUpDateSelect;
  final Function()? onUploadImage;
  final Function()? onSave;
  final Function() onAddVaccine;

  const WidgetAddMedicalCertificate({
    super.key,
    required this.certificateNumberController,
    this.selectedHospital,
    this.treatmentDate,
    this.hospitalizationStartDate,
    this.hospitalizationEndDate,
    this.sickLeaveStartDate,
    this.sickLeaveEndDate,
    this.followUpDate,
    required this.remarksController,
    this.imageBytes,
    this.isProcessingOcr = false, // 預設為false
    required this.onHospitalChanged,
    required this.onTreatmentDateSelect,
    required this.onHospitalizationStartDateSelect,
    required this.onHospitalizationEndDateSelect,
    required this.onSickLeaveStartDateSelect,
    required this.onSickLeaveEndDateSelect,
    required this.onFollowUpDateSelect,
    required this.onUploadImage,
    required this.onSave,
    required this.onAddVaccine,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // 醫院清單範例
    final List<String> hospitals = [
      localizations.hospitalNTW1,
      localizations.hospitalNTW2,
      localizations.hospitalNTE1,
      localizations.hospitalNTE2,
      localizations.hospitalKLW1,
      localizations.hospitalKLW2,
      localizations.hospitalKLW3,
      localizations.hospitalKLC1,
      localizations.hospitalKLC2,
      localizations.hospitalKLC3,
      localizations.hospitalHKW1,
      localizations.hospitalHKW2,
      localizations.hospitalOther,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.addMedicalCertificate,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 20),

          // 證明書編號
          _buildTextField(
            controller: certificateNumberController,
            labelText: localizations.certificateNumber,
          ),
          // 醫院選擇
          DropdownSearch<String>(
            selectedItem: selectedHospital ?? hospitals.first,
            items: (filter, props) => hospitals,
            onChanged: onHospitalChanged,
            decoratorProps: DropDownDecoratorProps(
              decoration: InputDecoration(
                labelText: localizations.hospital,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
              ),
            ),
            popupProps: PopupProps.menu(
              fit: FlexFit.loose,
              constraints: const BoxConstraints(),
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: localizations.searchHospital,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
              ),
              title: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(localizations.selectHospital),
              ),
            ),
          ),

          // 就診日期
          _buildDateSection(
            title: localizations.treatmentDate,
            value: treatmentDate,
            onDateSelected: onTreatmentDateSelect,
          ),

          // 住院期間
          _buildDateRangeSection(
            title: localizations.hospitalizationPeriod,
            startDate: hospitalizationStartDate,
            endDate: hospitalizationEndDate,
            onStartDateSelected: onHospitalizationStartDateSelect,
            onEndDateSelected: onHospitalizationEndDateSelect,
          ),

          // 病假期間
          _buildDateRangeSection(
            title: localizations.sickLeavePeriod,
            startDate: sickLeaveStartDate,
            endDate: sickLeaveEndDate,
            onStartDateSelected: onSickLeaveStartDateSelect,
            onEndDateSelected: onSickLeaveEndDateSelect,
          ),

          // 複診日期
          _buildDateSection(
            title: localizations.followUpDate,
            value: followUpDate,
            onDateSelected: onFollowUpDateSelect,
          ),

          // 備註
          _buildTextField(
            controller: remarksController,
            labelText: localizations.remarks,
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // 上傳圖片區域
          _buildImageUploadSection(context, localizations),

          const SizedBox(height: 24),

          // 儲存按鈕
          Center(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.save),
                label: Text(localizations.save, style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 構建文本輸入欄位
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        maxLines: maxLines,
      ),
    );
  }

  // 構建單一日期選擇區域
  Widget _buildDateSection({
    required String title,
    required String? value,
    required Function(String) onDateSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DateSelector(
          label: title,
          value: value,
          onDateSelected: onDateSelected,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // 構建日期範圍選擇區域
  Widget _buildDateRangeSection({
    required String title,
    required String? startDate,
    required String? endDate,
    required Function(String) onStartDateSelected,
    required Function(String) onEndDateSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DateSelector(
                label: '開始日期',
                value: startDate,
                onDateSelected: onStartDateSelected,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DateSelector(
                label: '結束日期',
                value: endDate,
                onDateSelected: onEndDateSelected,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // 構建圖片上傳區域
  Widget _buildImageUploadSection(BuildContext context, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              localizations.certificateImage,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            if (isProcessingOcr)
              Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    localizations.ocrProcessing,
                    style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (imageBytes != null) ...[
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.memory(
                        imageBytes!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (isProcessingOcr)
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              localizations.processingOcr,
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              ElevatedButton.icon(
                onPressed: onUploadImage,
                icon: const Icon(Icons.upload_file),
                label: Text(
                  imageBytes == null ? localizations.uploadAndScan : localizations.changeImage,
                  style: TextStyle(fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                ),
              ),
              if (imageBytes == null) ...[
                const SizedBox(height: 8),
                Text(
                  localizations.scanToFill,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
