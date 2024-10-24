import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      'label': 'To Do',
      'count': 45,
      'backgroundColor': Colors.blue,
      'labelColor': Colors.black,
      'countBackgroundColor': Colors.white,
      'countTextColor': Colors.black
    },
    {
      'label': 'In Progress',
      'count': 10,
      'backgroundColor': Colors.green,
      'labelColor': Colors.black,
      'countBackgroundColor': Colors.white,
      'countTextColor': Colors.black
    },
    {
      'label': 'In Review',
      'count': 5,
      'backgroundColor': Colors.orange,
      'labelColor': Colors.black,
      'countBackgroundColor': Colors.white,
      'countTextColor': Colors.black
    },
    {
      'label': 'Done',
      'count': 3,
      'backgroundColor': Colors.grey,
      'labelColor': Colors.black,
      'countBackgroundColor': Colors.white,
      'countTextColor': Colors.black
    },
  ];

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
                            legend: Legend(
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
                                dataLabelSettings: DataLabelSettings(
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
                                  child: Text(
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
                  Text('Activity Description'),
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
                            padding: EdgeInsets.symmetric(
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
            // Expanded ListView for Activities with no glow
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  TaskCard(
                    title: 'Task 1',
                    startDate: '10/10/2024',
                    endDate: '15/10/2024',
                  ),
                  TaskCard(
                    title: 'Task 2',
                    startDate: '12/10/2024',
                    endDate: '15/10/2024',
                  ),
                  TaskCard(
                    title: 'Task 3',
                    startDate: '13/10/2024',
                    endDate: '16/10/2024',
                  ),
                  TaskCard(
                    title: 'Task 4',
                    startDate: '14/10/2024',
                    endDate: '20/10/2024',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.status, this.value, this.color);
  final String status;
  final double value;
  final Color color;
}
