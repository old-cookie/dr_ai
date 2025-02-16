import 'package:flutter/material.dart';
import 'package:bmi_calculator/bmi_calculator.dart';
import '../services/service_theme.dart';
import '../widgets/widgets_units/widget_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    
    if (category == l10n.bmiSeverelyWasted ||
        category == l10n.bmiUnderweight ||
        category == l10n.bmiWasted) {
      return Colors.blue;
    } else if (category == l10n.bmiNormal ||
               category == l10n.bmiNormalWeight) {
      return Colors.green;
    } else if (category == l10n.bmiPossibleRiskOverweight ||
               category == l10n.bmiOverweight) {
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
                        Text(l10n.bmiClassificationTitle, 
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        ),
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
              ],
            ],
          ),
        ),
      ),
    );
  }
}
