import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String startDate;
  final String endDate;

  TaskCard({
    required this.title,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Card(
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.008),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenHeight * 0.018),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task title and menu button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.more_vert),
              ],
            ),
            SizedBox(height: screenHeight * 0.05),
            // Row for start date on the left and end date on the right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Start Date (left-aligned)
                Row(
                  children: [
                    const Icon(Icons.date_range),
                    const SizedBox(width: 4), // Space between icon and text
                    Text(
                      'Start: $startDate',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                // End Date (right-aligned)
                Row(
                  children: [
                    const Icon(Icons.date_range),
                    const SizedBox(width: 4), // Space between icon and text
                    Text(
                      'Due: $endDate',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
