import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screen_add_vaccine_record.dart';
import '../widgets/widgets_units/widget_button.dart';  // 添加此導入

class ScreenVaccineRecord extends StatelessWidget {
  const ScreenVaccineRecord({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: FutureBuilder<List<String>>(
          future: _loadSubmissions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading records.'));
            } else if (snapshot.data!.isEmpty) {
              return const Center(child: Text('No records found.'));
            } else {
              final submissions = snapshot.data!;
              return ListView.builder(
                itemCount: submissions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(submissions[index]),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Center(
              child: widgetButton(
                'Add Vaccination Record',
                Icons.add,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScreenAddVaccineRecord(),
                    ),
                  ).then((_) {
                    (context as Element).markNeedsBuild();
                  });
                },
                context: context,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<List<String>> _loadSubmissions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('submissions') ?? [];
  }
}