import 'package:flutter/material.dart';

class DatePicker extends StatefulWidget {
  const DatePicker({super.key});

  @override
  DatePickerState createState() => DatePickerState();
}

class DatePickerState extends State<DatePicker> {
  // Declare a variable to store the selected date
  DateTime selectedDate = DateTime.now();

  // Function to show the date picker dialog
  Future<void> _selectDate(BuildContext context) async {
    // Display the date picker and await user selection
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          selectedDate, // Set the initial date to the currently selected date
      firstDate: DateTime(2023, 1), // Set the minimum selectable date
      lastDate: DateTime(2023, 12), // Set the maximum selectable date
    );
    if (picked != null) {
      // If a date is selected, update the selectedDate variable and rebuild the UI
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Date Picker Example')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Display the selected date in a large text widget
            Text(
              "${selectedDate.toLocal()}".split(' ')[0],
              style: TextStyle(fontSize: 55, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            // Button to open the date picker dialog
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text('Select date'),
            ),
          ],
        ),
      ),
    );
  }
}
