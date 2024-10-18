import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tasks',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
      ),
      body: ProjectCard(),
    );
  }
}

class ProjectCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(children: [
      Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row for project title, time, and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ofspace project",
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
                    backgroundColor: Colors.blue.shade100,
                  ),
                ],
              ),
              SizedBox(height: 20),
              // "Overall activity" text
              Text(
                "Overall activity",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              // Progress indicator
              Center(
                child: CircularActivityIndicator(),
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}

class CircularActivityIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SfRadialGauge(axes: <RadialAxis>[
        RadialAxis(
          startAngle: 180,
          endAngle: 0,
          minimum: 0,
          maximum: 400, // Range based on To Do, In Progress, Done
          showLabels: false,
          showTicks: false,
          axisLineStyle: AxisLineStyle(
            thickness: 0.15,
            thicknessUnit: GaugeSizeUnit.factor,
            color: Colors.grey.shade200,
          ),
          pointers: <GaugePointer>[
            RangePointer(
              value: 200, // This value is for the progress
              width: 0.15,
              sizeUnit: GaugeSizeUnit.factor,
              gradient: SweepGradient(
                colors: [Colors.green, Colors.blue, Colors.purple],
                stops: [0.25, 0.5, 0.75],
              ),
              enableAnimation: true,
            ),
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: Text(
                '80%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              angle: 90,
              positionFactor: 0.1,
            )
          ],
        ),
      ]),
    );
  }
}
