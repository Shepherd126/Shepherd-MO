import 'package:flutter/material.dart';

class TaskCard extends StatefulWidget {
  final String title;
  final String description;
  final String? status; // Optional status with default as null

  const TaskCard({super.key, 
    required this.title,
    required this.description,
    this.status,
  });

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  String? currentStatus;

  @override
  void initState() {
    super.initState();
    // Initialize currentStatus to widget's status or null if not provided
    currentStatus = widget.status;
  }

  void updateStatus() {
    setState(() {
      if (currentStatus == 'To Do') {
        currentStatus = 'In Progress';
      } else if (currentStatus == 'In Progress') {
        currentStatus = 'In Review';
      } else if (currentStatus == 'In Review') {
        currentStatus = 'Done';
      } else if (currentStatus == 'Done') {
        currentStatus = 'To Do';
      }
    });
  }

  String getButtonText() {
    switch (currentStatus) {
      case 'To Do':
        return 'Mark as In Progress';
      case 'In Progress':
        return 'Mark as In Review';
      case 'In Review':
        return 'Mark as Done';
      case 'Done':
        return 'Reset to To Do';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Card(
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.008),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.all(screenHeight * 0.018),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.02),
                // Description Section
                Text(
                  widget.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                // Display status and button only if currentStatus is not null
                if (currentStatus != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status: $currentStatus',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: currentStatus == 'Done'
                              ? Colors.green
                              : currentStatus == 'In Progress'
                                  ? Colors.blue
                                  : currentStatus == 'In Review'
                                      ? Colors.orange
                                      : Colors.redAccent,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: updateStatus,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.blue, // Customize button color
                        ),
                        child: Text(
                          getButtonText(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
