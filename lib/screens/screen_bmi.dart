import 'package:flutter/material.dart';
import 'package:bmi_calculator/bmi_calculator.dart';
import '../services/service_theme.dart';
import '../widgets/widgets_units/widget_button.dart';
import '../../l10n/app_localizations.dart';

class ScreenBMI extends StatefulWidget {
  const ScreenBMI({super.key});

  @override
  State<ScreenBMI> createState() => _ScreenBMIState();
}

class _ScreenBMIState extends State<ScreenBMI> {
  final _formKey = GlobalKey<FormState>();
  double? height;
  double? weight;
  int? ageYears;
  String gender = "male";
  Standard standard = Standard.ASIAN;
  String? result;
  String? category;
  Color? categoryColor;

  void _calculateBMI() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final bmi = BMI(
        height: height! / 100,
        weight: weight!,
        ageYears: ageYears!,
        ageMonths: 0,
        gender: gender,
        standard: standard,
      );

      final bmiValue = bmi.computeBMI();
      final interpretation = bmi.interpretBMI();
      final l10n = AppLocalizations.of(context)!;

      // 轉換英文類別到本地化類別
      String localizedCategory = interpretation;
      switch (interpretation.toLowerCase()) {
        case "severely wasted":
          localizedCategory = l10n.bmiSeverelyWasted;
          break;
        case "wasted":
          localizedCategory = l10n.bmiWasted;
          break;
        case "underweight":
          localizedCategory = l10n.bmiUnderweight;
          break;
        case "normal":
        case "normal weight":
          localizedCategory = l10n.bmiNormal;
          break;
        case "possible risk of overweight":
          localizedCategory = l10n.bmiPossibleRiskOverweight;
          break;
        case "overweight":
          localizedCategory = l10n.bmiOverweight;
          break;
        case "obese":
          localizedCategory = l10n.bmiObese;
          break;
      }

      setState(() {
        result = bmiValue.toStringAsFixed(1);
        category = localizedCategory;
        categoryColor = _getCategoryColor(localizedCategory);
      });
    }
  }

  Color _getCategoryColor(String category) {
    final l10n = AppLocalizations.of(context)!;

    if (category == l10n.bmiSeverelyWasted || category == l10n.bmiUnderweight || category == l10n.bmiWasted) {
      return Colors.blue;
    } else if (category == l10n.bmiNormal || category == l10n.bmiNormalWeight) {
      return Colors.green;
    } else if (category == l10n.bmiPossibleRiskOverweight || category == l10n.bmiOverweight) {
      return Colors.orange;
    } else if (category == l10n.bmiObese) {
      return Colors.red;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bmiCalculator),
        backgroundColor: themeCurrent(context).colorScheme.surface,
        foregroundColor: themeCurrent(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: l10n.bmiHeight,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return l10n.bmiValidationEnterHeight;
                  final height = double.tryParse(value);
                  if (height == null || height <= 0) return l10n.bmiValidationInvalidHeight;
                  return null;
                },
                onSaved: (value) => height = double.parse(value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: l10n.bmiWeight,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return l10n.bmiValidationEnterWeight;
                  final weight = double.tryParse(value);
                  if (weight == null || weight <= 0) return l10n.bmiValidationInvalidWeight;
                  return null;
                },
                onSaved: (value) => weight = double.parse(value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: l10n.bmiAge,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return l10n.bmiValidationEnterAge;
                  final age = int.tryParse(value);
                  if (age == null || age <= 0) return l10n.bmiValidationInvalidAge;
                  return null;
                },
                onSaved: (value) => ageYears = int.parse(value!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: l10n.bmiGender,
                        border: const OutlineInputBorder(),
                      ),
                      value: gender,
                      items: [
                        DropdownMenuItem(value: 'male', child: Text(l10n.bmiMale)),
                        DropdownMenuItem(value: 'female', child: Text(l10n.bmiFemale)),
                      ],
                      onChanged: (value) => setState(() => gender = value!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<Standard>(
                      decoration: InputDecoration(
                        labelText: l10n.bmiStandard,
                        border: const OutlineInputBorder(),
                      ),
                      value: standard,
                      items: [
                        DropdownMenuItem(value: Standard.ASIAN, child: Text(l10n.bmiAsian)),
                        DropdownMenuItem(value: Standard.WHO, child: Text(l10n.bmiWHO)),
                      ],
                      onChanged: (value) => setState(() => standard = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 60,
                child: widgetButton(
                  l10n.bmiCalculate,
                  Icons.calculate_outlined,
                  _calculateBMI,
                  context: context,
                  color: themeCurrent(context).colorScheme.primary,
                ),
              ),
              if (result != null) ...[
                const SizedBox(height: 32),
                Text(
                  l10n.bmiResult(result!),
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  category!,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: categoryColor,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.bmiClassificationTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        if (ageYears! >= 5 && ageYears! <= 19) ...[
                          Text(l10n.bmiChildStandard),
                          Text(l10n.bmiChildSeverelyWasted),
                          Text(l10n.bmiChildWasted),
                          Text(l10n.bmiChildNormal),
                          Text(l10n.bmiChildRiskOverweight),
                          Text(l10n.bmiChildOverweight),
                          Text(l10n.bmiChildObese),
                        ] else if (standard == Standard.ASIAN) ...[
                          Text(l10n.bmiAsianAdultStandard),
                          Text(l10n.bmiAsianUnderweight),
                          Text(l10n.bmiAsianNormal),
                          Text(l10n.bmiAsianOverweight),
                          Text(l10n.bmiAsianObese),
                        ] else ...[
                          Text(l10n.bmiWHOAdultStandard),
                          Text(l10n.bmiWHOUnderweight),
                          Text(l10n.bmiWHONormal),
                          Text(l10n.bmiWHOOverweight),
                          Text(l10n.bmiWHOObese),
                        ],
                      ],
                    ),
                  ),
                ),
                if (double.parse(result!) < 18.5) ...[
                  const SizedBox(height: 32),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '體重過輕（BMI < 18.5）',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '增加熱量攝取：選擇高熱量且營養豐富的食物，如堅果、牛油果、全脂乳製品等。\n'
                            '頻繁進食：每天進食5-6餐，並確保每餐都包含蛋白質、碳水化合物和健康脂肪。\n'
                            '力量訓練：進行力量訓練以增加肌肉量，這有助於提高體重和改善體型。',
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (double.parse(result!) >= 18.5 && double.parse(result!) < 24) ...[
                  const SizedBox(height: 32),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '健康體重（18.5 ≤ BMI < 24）',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '維持均衡飲食：繼續保持健康的飲食習慣，確保攝取足夠的營養素。\n'
                            '定期運動：每週至少150分鐘的中等強度運動，以維持健康的體重和心血管健康。\n'
                            '監測體重：定期檢查體重，確保不會出現過度增重或減重的情況。',
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (double.parse(result!) >= 24 && double.parse(result!) < 27) ...[
                  const SizedBox(height: 32),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '體重過重（24 ≤ BMI < 27）',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '減少熱量攝取：控制每日熱量攝取，選擇低熱量、高纖維的食物，如蔬菜和全穀類。\n'
                            '增加運動量：每週增加運動時間，目標是至少150-300分鐘的有氧運動。\n'
                            '飲食日記：記錄每日飲食，幫助識別不健康的飲食習慣。',
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (double.parse(result!) >= 28 && double.parse(result!) < 35) ...[
                  const SizedBox(height: 32),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '中度肥胖（28 ≤ BMI < 35）',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '嚴格控制飲食：減少高熱量、高糖和高脂肪的食物攝取，增加蔬菜和水果的比例。\n'
                            '定期運動：每週至少進行300分鐘的有氧運動，並結合力量訓練。\n'
                            '健康監測：定期檢查血糖、血壓和膽固醇水平，及早發現健康問題。',
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (double.parse(result!) >= 35) ...[
                  const SizedBox(height: 32),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '重度肥胖（BMI ≥ 35）',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '醫療介入：考慮尋求醫療專業的幫助，可能需要藥物治療或手術介入。\n'
                            '全面的生活方式改變：結合飲食、運動和行為改變，制定全面的減重計劃。\n'
                            '心理支持：尋求心理諮詢，幫助應對減重過程中的情緒和心理挑戰。',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
