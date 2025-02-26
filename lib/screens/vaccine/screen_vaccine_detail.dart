import 'package:flutter/material.dart';
import '../../widgets/widgets_screens/vaccine/widget_vaccine_detail.dart';
import '../../l10n/app_localizations.dart';

/// 疫苗接種詳細資訊顯示畫面
/// 顯示單筆疫苗接種記錄的完整資訊，包含圖片
class ScreenVaccineDetail extends StatelessWidget {
  final Map<String, dynamic> record;

  const ScreenVaccineDetail({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.vaccineDetailTitle ?? 'Vaccination Details'),
      ),
      body: WidgetVaccineDetail(record: record),
    );
  }
}
