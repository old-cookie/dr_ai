import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screen_add_vaccine_record.dart'; // Import the ListOfStringScreen

class ScreenVaccineRecord extends StatelessWidget {
  const ScreenVaccineRecord({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
      ),
      body: FutureBuilder<List<String>>(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ScreenAddVaccineRecord(),
            ),
          ).then((_) {
            // Refresh the ResultScreen when returning
            (context as Element).markNeedsBuild();
          });
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Vaccination Record',
      ),
    );
  }

  Future<List<String>> _loadSubmissions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('submissions') ?? [];
  }
}