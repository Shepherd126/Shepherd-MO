import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shepherd_mo/models/task.dart';
import 'package:shepherd_mo/providers/provider.dart';
import 'package:shepherd_mo/widgets/task_card.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  int selectedIndex = 0;

  final List<Map<String, dynamic>> statusList = [
    {'label': 'All', 'count': 4, 'backgroundColor': Colors.blue},
    {'label': 'To Do', 'count': 1, 'backgroundColor': Colors.yellow},
    {'label': 'In Progress', 'count': 1, 'backgroundColor': Colors.blue},
    {'label': 'In Review', 'count': 1, 'backgroundColor': Colors.orange},
    {'label': 'Done', 'count': 1, 'backgroundColor': Colors.green},
  ];

  List<Task> tasks = [
    Task(
        title: 'Task 1',
        description:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        status: 'To Do'),
    Task(
        title: 'Task 2',
        description:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        status: 'In Progress'),
    Task(
        title: 'Task 3',
        description:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        status: 'In Review'),
    Task(
        title: 'Task 4',
        description:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        status: 'Done'),
  ];

  List<Task> filteredTasks = [];

  @override
  void initState() {
    filterTasks();
    super.initState();
  }

  void filterTasks() {
    setState(() {
      if (selectedIndex == 0) {
        filteredTasks = tasks; // Show all tasks
      } else {
        String selectedStatus = statusList[selectedIndex]['label'];
        filteredTasks =
            tasks.where((task) => task.status == selectedStatus).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UIProvider>(context);
    bool isDark = uiProvider.themeMode == ThemeMode.dark ||
        (uiProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tasks',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        child: Column(
          children: [
            // Header Card with Event Details
            _buildEventHeaderCard(screenWidth, isDark),
            SizedBox(height: screenHeight * 0.02),

            // Activity Details Section
            _buildActivityDetails(screenHeight, screenWidth),

            // Section Title
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                child: Text(
                  'Tasks',
                  style: TextStyle(
                    fontSize: screenHeight * 0.025,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Filtered Task List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  return TaskCard(
                    title: task.title,
                    description: task.description,
                    status: task.status,
                  );
                },
              ),
            ),

            // Status Chips Row for Filtering
            _buildStatusChipsRow(screenWidth, screenHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildEventHeaderCard(double screenWidth, bool isDark) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
      ),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.03),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Project title, time, and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Event Name",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16),
                        SizedBox(width: 5),
                        Text("10:00 am - 12:00 pm"),
                      ],
                    ),
                  ],
                ),
                // Status Chip
                Chip(
                  label: Text(
                    "On Going",
                    style:
                        TextStyle(color: isDark ? Colors.black : Colors.white),
                  ),
                  backgroundColor: Colors.blue.shade400,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityDetails(double screenHeight, double screenWidth) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Name',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenHeight * 0.025,
              ),
            ),
            const ExpandableText(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
              expandText: 'Show More',
              collapseText: 'Show Less',
              linkColor: Colors.blue,
              animation: true,
              textScaleFactor: 1.1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChipsRow(double screenWidth, double screenHeight) {
    double chipSpacing = screenWidth * 0.03;
    double fontSize = screenWidth * 0.04;
    double countFontSize = screenWidth * 0.035;

    return Container(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(
          spacing: chipSpacing,
          children: List<Widget>.generate(
            statusList.length,
            (int index) {
              var status = statusList[index];
              return ChoiceChip(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      status['label'],
                      style: TextStyle(
                        color: selectedIndex == index
                            ? Colors.white
                            : Colors.black,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: selectedIndex == index
                            ? Colors.white.withOpacity(0.5)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${status['count']}',
                        style: TextStyle(
                          color: selectedIndex == index
                              ? Colors.black
                              : Colors.grey.shade700,
                          fontSize: countFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                showCheckmark: false,
                selectedColor: status['backgroundColor'],
                backgroundColor: Colors.grey.shade300,
                selected: selectedIndex == index,
                onSelected: (bool selected) {
                  setState(() {
                    selectedIndex = selected ? index : 0;
                    filterTasks();
                  });
                },
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}
