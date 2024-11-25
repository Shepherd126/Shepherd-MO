import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shepherd_mo/api/api_service.dart';
import 'package:shepherd_mo/controller/controller.dart';
import 'package:shepherd_mo/models/task.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shepherd_mo/widgets/task_detail_dialog.dart';
import 'package:shepherd_mo/providers/signalr_provider.dart';
import 'package:shepherd_mo/providers/ui_provider.dart';
import 'package:shepherd_mo/utils/toast.dart';

class UpdateProgress extends StatefulWidget {
  final List<Task> tasks;

  const UpdateProgress({super.key, required this.tasks});

  @override
  _UpdateProgressState createState() => _UpdateProgressState();
}

class _UpdateProgressState extends State<UpdateProgress> {
  final List<String> statuses = [
    'Việc cần làm',
    'Đang thực hiện',
    'Xem xét',
    'Đã hoàn thành'
  ];
  final Map<String, Color> statusColors = {
    'Việc cần làm': Colors.blueAccent,
    'Đang thực hiện': Colors.orangeAccent,
    'Xem xét': Colors.redAccent,
    'Đã hoàn thành': Colors.green,
  };
  final apiService = ApiService();

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RefreshController taskController = Get.find();
      taskController.setShouldRefresh(true);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final localizations = AppLocalizations.of(context)!;
    final uiProvider = Provider.of<UIProvider>(context);
    bool isDark = uiProvider.themeMode == ThemeMode.dark ||
        (uiProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Consumer<SignalRService>(
      builder: (context, signalRService, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              localizations.updateProgress,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            centerTitle: true,
            elevation: 4,
          ),
          body: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                        child: buildStatusColumn(localizations.toDo,
                            screenWidth, screenHeight, localizations, isDark)),
                    Expanded(
                        child: buildStatusColumn(localizations.inProgress,
                            screenWidth, screenHeight, localizations, isDark)),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                        child: buildStatusColumn(localizations.review,
                            screenWidth, screenHeight, localizations, isDark)),
                    Expanded(
                        child: buildStatusColumn(localizations.done,
                            screenWidth, screenHeight, localizations, isDark)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildStatusColumn(String status, double screenWidth,
      double screenHeight, AppLocalizations localizations, bool isDark) {
    final statusTasks =
        widget.tasks.where((task) => task.status == status).toList();
    final taskCount = statusTasks.length;

    return Container(
      margin: EdgeInsets.all(screenWidth * 0.01),
      decoration: BoxDecoration(
        color: statusColors[status]!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(
            color: statusColors[status]!, width: screenWidth * 0.003),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.01, horizontal: screenWidth * 0.03),
            decoration: BoxDecoration(
              color: statusColors[status]!.withOpacity(0.3),
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(screenWidth * 0.03)),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w900,
                      color: statusColors[status],
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.015),
                  Container(
                    width: screenWidth * 0.06,
                    height: screenWidth * 0.06,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: statusColors[status]!.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$taskCount',
                      style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w900,
                          color: statusColors[status]!),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: DragTarget<Task>(
              onWillAcceptWithDetails: (details) => details.data != null,
              onAcceptWithDetails: (details) async {
                final task = details.data;

                if (task.status != status) {
                  // Save the original status
                  final originalStatus = task.status;

                  bool success =
                      await apiService.updateTaskStatus(task, status);

                  if (success) {
                    setState(() {
                      task.status = status;
                    });
                    showToast(
                        "${localizations.updateProgress} ${localizations.success.toLowerCase()}");
                  } else {
                    showToast(
                        "${localizations.updateProgress} ${localizations.unsuccess.toLowerCase()}");
                  }
                }
              },
              builder: (context, candidateData, rejectedData) {
                bool isDraggingOver = candidateData.isNotEmpty;

                return Container(
                  color: isDraggingOver
                      ? statusColors[status]!.withOpacity(0.2)
                      : Colors.transparent,
                  child: statusTasks.isNotEmpty
                      ? SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.01,
                              horizontal: screenWidth * 0.01),
                          child: Column(
                            children: statusTasks
                                .map((task) => DraggableTaskCard(
                                    key: ObjectKey(task), task: task))
                                .toList(),
                          ),
                        )
                      : Center(
                          child: Text(
                            localizations.dragToUpdate,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DraggableTaskCard extends StatelessWidget {
  final Task task;

  const DraggableTaskCard({required Key key, required this.task})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<Task>(
      data: task,
      feedback: Material(
        color: Colors.transparent,
        child: KanbanTaskCard(task: task, isDragging: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: KanbanTaskCard(task: task, isDragging: false),
      ),
      child: KanbanTaskCard(task: task),
    );
  }
}

class KanbanTaskCard extends StatelessWidget {
  final Task task;
  final bool isDragging;

  const KanbanTaskCard(
      {super.key, required this.task, this.isDragging = false});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final localizations = AppLocalizations.of(context)!;
    final uiProvider = Provider.of<UIProvider>(context);
    bool isDark = uiProvider.themeMode == ThemeMode.dark ||
        (uiProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return TaskDetailsDialog(
              task: task, // Pass the task object
            );
          },
        );
      },
      child: Container(
        width: isDragging ? null : double.infinity,
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
        child: Card(
          color: isDark
              ? (isDragging ? Colors.grey[900] : Colors.grey.shade700)
              : (isDragging ? Colors.grey[300] : Colors.white),
          elevation: isDragging ? 8 : 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.03),
            child: Text(
              task.title ?? localizations.noData,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
