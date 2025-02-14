import 'package:flutter/material.dart';
import '../../widgets/widgets_screens/vaccine/widget_vaccine_record.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// 疫苗記錄管理畫面
/// 提供疫苗接種記錄的查看、新增和刪除功能
class ScreenVaccineRecord extends StatelessWidget {
  const ScreenVaccineRecord({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.vaccineRecordTitle ?? 'Vaccine Record'),
      ),
      body: const WidgetVaccineRecord(),
    );
  }
}
