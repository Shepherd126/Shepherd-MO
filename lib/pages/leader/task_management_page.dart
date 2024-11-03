import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shepherd_mo/models/task.dart';
import 'package:shepherd_mo/providers/provider.dart';
import 'package:shepherd_mo/widgets/task_card.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TaskManagementPage extends StatefulWidget {
  const TaskManagementPage({super.key});

  @override
  State<TaskManagementPage> createState() => _TaskManagementPageState();
}

class _TaskManagementPageState extends State<TaskManagementPage> {
  int selectedIndex = -1;
  final List<Map<String, dynamic>> statusList = [
    {
      'label': 'All',
      'count': 4,
      'backgroundColor': Colors.blue,
      'labelColor': Colors.black,
      'countBackgroundColor': Colors.white,
      'countTextColor': Colors.black
    },
    {
      'label': 'To Do',
      'count': 1,
      'backgroundColor': Colors.yellow,
      'labelColor': Colors.black,
      'countBackgroundColor': Colors.white,
      'countTextColor': Colors.black
    },
    {
      'label': 'In Progress',
      'count': 1,
      'backgroundColor': Colors.blue,
      'labelColor': Colors.black,
      'countBackgroundColor': Colors.white,
      'countTextColor': Colors.black
    },
    {
      'label': 'In Review',
      'count': 1,
      'backgroundColor': Colors.orange,
      'labelColor': Colors.black,
      'countBackgroundColor': Colors.white,
      'countTextColor': Colors.black
    },
    {
      'label': 'Done',
      'count': 1,
      'backgroundColor': Colors.green,
      'labelColor': Colors.black,
      'countBackgroundColor': Colors.white,
      'countTextColor': Colors.black
    },
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
        status: 'In Progres'),
    Task(
        title: 'Task 3',
        description:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        status: 'To do'),
    Task(
        title: 'In Review',
        description:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        status: 'Done'),
  ];
  List<String> users = ['Nguyễn Văn A', 'Nguyễn Thị B', 'Trần Văn C'];
  void onSubmit(String name, String description, String user) {}

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UIProvider>(context);
    bool isDark = uiProvider.themeMode == ThemeMode.dark ||
        (uiProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'task',
        onPressed: () {
          showTaskDialog(context: context, users: users, onSubmit: onSubmit);
        },
        backgroundColor: Colors.orange,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
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
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
              ),
              elevation: 5,
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.03),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row for project title, time, and status
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
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 16),
                                SizedBox(width: 5),
                                Text("10:00 am - 12:00 am"),
                              ],
                            ),
                          ],
                        ),
                        // Status chip
                        Chip(
                          label: Text(
                            "On Going",
                            style: TextStyle(
                                color: isDark ? Colors.black : Colors.white),
                          ),
                          backgroundColor: Colors.blue.shade50,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ],
                    ),
                    // Progress indicator
                    SizedBox(
                      height: screenHeight * 0.25,
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: SfCircularChart(
                            legend: const Legend(
                                isVisible: true,
                                position: LegendPosition.bottom),
                            series: <CircularSeries>[
                              DoughnutSeries<ChartData, String>(
                                dataSource: [
                                  ChartData(
                                      'Done', 20, Colors.greenAccent.shade700),
                                  ChartData(
                                      'To Do', 40, Colors.blueAccent.shade700),
                                  ChartData('In Progress', 20,
                                      Colors.orange.shade600),
                                  ChartData(
                                      'In Review', 20, Colors.red.shade700),
                                ],
                                pointColorMapper: (ChartData data, _) =>
                                    data.color,
                                xValueMapper: (ChartData data, _) =>
                                    data.status,
                                yValueMapper: (ChartData data, _) => data.value,
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: false,
                                  textStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                innerRadius: '70%', // Creates a doughnut effect
                              ),
                            ],
                            annotations: <CircularChartAnnotation>[
                              CircularChartAnnotation(
                                widget: Container(
                                  child: const Text(
                                    '80%',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.025),
            Align(
              alignment: Alignment.topLeft,
              child: Column(
                children: [
                  Text(
                    'Activity Name',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenHeight * 0.025),
                  ),
                  const Text('Activity Description'),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.025),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: screenWidth * 0.03,
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
                                  : status['labelColor'],
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: selectedIndex == index
                                  ? Colors.white.withOpacity(0.5)
                                  : status['countBackgroundColor'],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${status['count']}',
                              style: TextStyle(
                                color: selectedIndex == index
                                    ? status['countTextColor']
                                    : Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      showCheckmark: false,
                      selectedColor: status[
                          'backgroundColor'], // Background color when selected
                      backgroundColor: Colors.grey.shade300,
                      selected: selectedIndex == index,
                      onSelected: (bool selected) {
                        setState(() {
                          selectedIndex = selected ? index : -1;
                        });
                      },
                    );
                  },
                ).toList(),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return TaskCard(
                    title: task.title,
                    description: task.description,
                    status: task.status,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showTaskDialog({
  required BuildContext context,
  String? initialName,
  String? initialDescription,
  String? selectedUser,
  required List<String> users, // List of users to assign
  required Function(String name, String description, String assignedUser)
      onSubmit,
}) async {
  final TextEditingController nameController =
      TextEditingController(text: initialName);
  final TextEditingController descriptionController =
      TextEditingController(text: initialDescription);
  String? assignedUser = selectedUser;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows the dialog to take full height if needed
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dialog Title
              Text(
                initialName == null ? 'Create Task' : 'Edit Task',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Name Field
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // Description Field
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 10),

              // Assign to User Field
              DropdownButtonFormField<String>(
                value: assignedUser,
                onChanged: (String? newValue) {
                  assignedUser = newValue;
                },
                items: users.map<DropdownMenuItem<String>>((String user) {
                  return DropdownMenuItem<String>(
                    value: user,
                    child: Text(user),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Assign to User',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Dialog Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty &&
                          descriptionController.text.isNotEmpty &&
                          assignedUser != null) {
                        onSubmit(nameController.text,
                            descriptionController.text, assignedUser!);
                        Navigator.of(context).pop(); // Close the dialog
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill all fields')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.blue, // Distinct color for Save button
                    ),
                    child: const Text('Save'),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    style: TextButton.styleFrom(
                      backgroundColor:
                          Colors.red, // Distinct color for Cancel button
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class ChartData {
  ChartData(this.status, this.value, this.color);
  final String status;
  final double value;
  final Color color;
}
