import 'package:flutter/material.dart';
import 'package:shepherd_mo/widgets/activity_card.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
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
                        Column(
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
                          label: Text("On Going"),
                          backgroundColor: Colors.blue.shade50,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'Progress',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenHeight * 0.025),
                    ),
                    // Progress indicator
                    SizedBox(
                      height: screenHeight * 0.22,
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: SfRadialGauge(
                            axes: <RadialAxis>[
                              RadialAxis(
                                startAngle: 120,
                                endAngle: 60,
                                minimum: 0,
                                maximum: 100,
                                showLabels: true,
                                maximumLabels: 2,
                                showLastLabel: true,
                                axisLineStyle: AxisLineStyle(
                                  thickness: 0.25,
                                  thicknessUnit: GaugeSizeUnit.factor,
                                  color: Colors.grey.shade200,
                                ),
                                pointers: <GaugePointer>[
                                  RangePointer(
                                    value: 80,
                                    width: 0.25,
                                    sizeUnit: GaugeSizeUnit.factor,
                                    gradient: SweepGradient(
                                      colors: [
                                        Colors.greenAccent.shade700,
                                        Colors.greenAccent.shade400,
                                        Colors.greenAccent
                                      ],
                                      stops: [0.25, 0.5, 0.75],
                                    ),
                                    enableAnimation: true,
                                  ),
                                ],
                                annotations: const <GaugeAnnotation>[
                                  GaugeAnnotation(
                                    widget: Text(
                                      '80%',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
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
                  ActivityCard(
                    title: 'Dashboard design for admin',
                    startDate: '10/10/2024',
                    endDate: '15/10/2024',
                  ),
                  ActivityCard(
                    title: 'Konom web application',
                    startDate: '12/10/2024',
                    endDate: '15/10/2024',
                  ),
                  ActivityCard(
                    title: 'Research and development',
                    startDate: '13/10/2024',
                    endDate: '16/10/2024',
                  ),
                  ActivityCard(
                    title: 'Event booking application',
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
