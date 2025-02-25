import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

import 'dart:typed_data';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

  // 各種事件回調函數
  final Function(String?) onHospitalChanged;
  final Function(String) onTreatmentDateSelect;
  final Function(String) onHospitalizationStartDateSelect;
  final Function(String) onHospitalizationEndDateSelect;
  final Function(String) onSickLeaveStartDateSelect;
  final Function(String) onSickLeaveEndDateSelect;
  final Function(String) onFollowUpDateSelect;
  final Function() onUploadImage;
  final Function() onSave;
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
      '台大醫院',
      '榮民總醫院',
      '三軍總醫院',
      '長庚醫院',
      '馬偕醫院',
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
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      maxLines: maxLines,
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
        Text(
          localizations.certificateImage,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.memory(
                    imageBytes!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              ElevatedButton.icon(
                onPressed: onUploadImage,
                icon: const Icon(Icons.upload_file),
                label: Text(imageBytes == null ? localizations.uploadImage : localizations.changeImage),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
