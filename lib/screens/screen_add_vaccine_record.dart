import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import '../widgets/widgets_units/mirai_dropdown_list_of_strings_widget.dart';
import '../widgets/widgets_units/mirai_dropdown_item_widget.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screen_vaccine_record.dart'; // Ensure you import the Result screen
import '../widgets/widgets_units/widget_button.dart';
import '../widgets/widgets_units/widget_title.dart';

class ScreenAddVaccineRecord extends StatefulWidget {
  const ScreenAddVaccineRecord({super.key});

  @override
  State<ScreenAddVaccineRecord> createState() => _ScreenAddVaccineRecordState();
}

class _ScreenAddVaccineRecordState extends State<ScreenAddVaccineRecord> {
  // Lists for dropdown items
  final List<String> listOfItem = <String>[
    'COVID-19 vaccine',
    'Hepatitis A vaccine',
    'Hepatitis B vaccine',
    'Herpes Zoster vaccine',
    'HPV 9-Valent vaccine',
    'Influenza Seasonal vaccine',
  ];

  final List<String> secondListOfItem = <String>[
    '1st',
    '2nd',
    '3rd',
  ];

  final List<String> thirdListOfItem = <String>[
    'Department of Health/Hospital Authority',
    'Elderly Home',
    'Private Clinic/Hospital',
    'School',
  ];

  // Value Notifiers for dropdown selections
  late ValueNotifier<String> valueNotifierFirst;
  late ValueNotifier<String> valueNotifierSecond;
  late ValueNotifier<String> valueNotifierThird;

  // Controllers for user input
  final TextEditingController remarkController = TextEditingController();
  String? selectedDate;

  @override
  void initState() {
    super.initState();
    valueNotifierFirst = ValueNotifier<String>(listOfItem.first);
    valueNotifierSecond = ValueNotifier<String>(secondListOfItem.first);
    valueNotifierThird = ValueNotifier<String>(thirdListOfItem.first);
  }

  void _saveRecord() async {
  // Collect data from the form
  String selectedVaccine = valueNotifierFirst.value;
  String selectedDose = valueNotifierSecond.value;
  String selectedPlace = valueNotifierThird.value;
  String remarks = remarkController.text;

  // Get the instance of SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Create a unique key for the record
  String record = '${selectedDate ?? 'Not selected'} - $selectedVaccine - $selectedDose - $selectedPlace - $remarks';

  // Retrieve existing submissions, if any
  final submissions = prefs.getStringList('submissions') ?? [];
  
  // Add the new record to the list
  submissions.add(record);
  
  // Save the updated submissions list
  await prefs.setStringList('submissions', submissions);

  // Navigate back to the Result page
  Navigator.pop(context); // This returns to the Result page
}

  void _openDatePicker(BuildContext context) {
    BottomPicker.date(
      pickerTitle: const Text(
        'Select Date',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      initialDateTime: DateTime.now(),
      maxDateTime: DateTime.now(),
      minDateTime: DateTime(1980),
      pickerTextStyle: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      onChange: (index) {
        print(index);
      },
      onSubmit: (date) {
        setState(() {
          selectedDate = '${date.month}/${date.day}/${date.year}'; 
        });
        print(selectedDate); // Print the formatted date
      },
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaccines Record'),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 16),

            // First Dropdown for Vaccine Selection
            widgetTitle('Vaccine Name', top: 0, bottom: 8),
            MiraiDropdownWidget<String>(
              valueNotifier: valueNotifierFirst,
              showOtherAndItsTextField: true,
              showSearchTextField: true,
              itemMargin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              itemWidgetBuilder: (int index, String? item, {bool isItemSelected = false}) {
                return MiraiDropDownItemWidget(
                  item: item,
                  isItemSelected: isItemSelected,
                );
              },
              children: listOfItem,
              onChanged: (String value) {
                valueNotifierFirst.value = value;
              },
            ),

            const SizedBox(height: 16),

            // Second Dropdown for Dose Sequence
            widgetTitle('Dose Sequence', top: 0, bottom: 8),
            MiraiDropdownWidget<String>(
              valueNotifier: valueNotifierSecond,
              showOtherAndItsTextField: true,
              showSearchTextField: true,
              itemMargin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              itemWidgetBuilder: (int index, String? item, {bool isItemSelected = false}) {
                return MiraiDropDownItemWidget(
                  item: item,
                  isItemSelected: isItemSelected,
                );
              },
              children: secondListOfItem,
              onChanged: (String value) {
                valueNotifierSecond.value = value;
              },
            ),

            const SizedBox(height: 16),

            // Date Picker Section
            widgetTitle('Date Received', top: 0, bottom: 8),
            ElevatedButton(
              onPressed: () => _openDatePicker(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text('Select Date'),
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
            widgetTitle('Place Given (Optional)', top: 0, bottom: 8),
            MiraiDropdownWidget<String>(
              valueNotifier: valueNotifierThird,
              showOtherAndItsTextField: true,
              showSearchTextField: true,
              itemMargin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              itemWidgetBuilder: (int index, String? item, {bool isItemSelected = false}) {
                return MiraiDropDownItemWidget(
                  item: item,
                  isItemSelected: isItemSelected,
                );
              },
              children: thirdListOfItem,
              onChanged: (String value) {
                valueNotifierThird.value = value;
              },
            ),

            const SizedBox(height: 16),

            // Remark Section
            widgetTitle('Remark (Optional)', top: 0, bottom: 8),
            TextField(
              controller: remarkController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Other information',
              ),
            ),

            const SizedBox(height: 16),

            // Save Button
            widgetButton(
              'Save',
              Icons.save,
              _saveRecord,
              context: context,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      )
    );
  }
}