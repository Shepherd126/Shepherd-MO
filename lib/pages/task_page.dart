import 'package:flutter/material.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shepherd_mo/api/api_service.dart';
import 'package:shepherd_mo/constant/constant.dart';
import 'package:shepherd_mo/controller/controller.dart';
import 'package:shepherd_mo/models/activity.dart';
import 'package:shepherd_mo/models/event.dart';
import 'package:shepherd_mo/models/group_role.dart';
import 'package:shepherd_mo/models/task.dart';
import 'package:shepherd_mo/pages/update_progress.dart';
import 'package:shepherd_mo/providers/ui_provider.dart';
import 'package:shepherd_mo/services/get_login.dart';
import 'package:shepherd_mo/widgets/empty_data.dart';
import 'package:shepherd_mo/widgets/end_of_line.dart';
import 'package:shepherd_mo/widgets/task_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TaskPage extends StatefulWidget {
  final String activityId;
  final String activityName;
  final GroupRole group;

  const TaskPage(
      {super.key,
      required this.activityId,
      required this.activityName,
      required this.group});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  int selectedIndex = 0;
  final PagingController<int, Task> _pagingController =
      PagingController(firstPageKey: 1);
  final int _pageSize = 10;
  String? eventId;
  Future<Map<String, dynamic>>? _initialData;
  final taskController = Get.find<TaskController>();

  final List<Map<String, dynamic>> statusList = [
    {'label': 'All', 'backgroundColor': Colors.blue},
    {'label': 'To Do', 'backgroundColor': Colors.yellow},
    {'label': 'In Progress', 'backgroundColor': Colors.blue},
    {'label': 'Review', 'backgroundColor': Colors.orange},
    {'label': 'Done', 'backgroundColor': Colors.green},
  ];
  List<Task> _allTasks = [];

  @override
  void initState() {
    super.initState();
    _initialData = fetchData();
    _pagingController.addPageRequestListener((pageKey) {
      if (eventId != null) {
        _fetchTasks(pageKey);
      }
    });
  }

  Future<Map<String, dynamic>> fetchData() async {
    ApiService apiService = ApiService();
    final results =
        await apiService.fetchActivities(searchKey: widget.activityId) ?? [];
    final data = results.first;

    setState(() {
      eventId = data['event']['id'];
    });

    return {
      'activity': Activity.fromJson(data),
      'event': Event.fromJson(data['event']),
    };
  }

  Future<void> _fetchTasks(int pageKey) async {
    final apiService = ApiService();
    String selectedStatus =
        selectedIndex == 0 ? '' : statusList[selectedIndex]['label'];
    final loginInfo = await getLoginInfoFromPrefs();

    try {
      final newTasks = await apiService.fetchTasks(
        searchKey: '',
        pageNumber: pageKey,
        pageSize: _pageSize,
        groupId: widget.group.groupId,
        activityId: widget.activityId,
        eventId: eventId,
        userId: loginInfo!.id,
        status: selectedStatus,
      );

      if (selectedIndex == 0) {
        _allTasks = newTasks;
        _updateTaskCounts();
      } else {
        _updateTaskCounts();
      }
      final isLastPage = newTasks.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newTasks);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newTasks, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  void _updateTaskCounts() {
    final taskCounts = {
      'All': _allTasks.length,
      'To Do': _allTasks.where((task) => task.status == 'To Do').length,
      'In Progress':
          _allTasks.where((task) => task.status == 'In Progress').length,
      'Review': _allTasks.where((task) => task.status == 'Review').length,
      'Done': _allTasks.where((task) => task.status == 'Done').length,
    };

    setState(() {
      for (var status in statusList) {
        status['count'] = taskCounts[status['label']] ?? 0;
      }
    });
  }

  String formatEventDateRange(DateTime? fromDate, DateTime? toDate) {
    if (fromDate == null || toDate == null) return 'Invalid date range';
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    final date = dateFormat.format(fromDate);
    final fromTime = timeFormat.format(fromDate);
    final toTime = timeFormat.format(toDate);
    return '$date | $fromTime - $toTime';
  }

  Future<void> _refreshList() async {
    _pagingController.refresh();
  }

  void _filterTasksByStatus() {
    _pagingController.refresh();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UIProvider>(context);
    bool isDark = uiProvider.themeMode == ThemeMode.dark ||
        (uiProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    final localizations = AppLocalizations.of(context)!;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.task,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _initialData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final activity = snapshot.data!['activity'] as Activity;
            final event = snapshot.data!['event'] as Event;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Header Card
                  _buildEventHeaderCard(
                    screenWidth,
                    screenHeight,
                    isDark,
                    event,
                    localizations,
                  ),

                  // Activity Details
                  _buildActivityDetails(screenHeight, screenWidth, activity,
                      localizations, isDark),

                  // Tasks Section with Heading and Status Chips
                  Container(
                    padding: EdgeInsets.only(
                        top: screenWidth * 0.04,
                        left: screenWidth * 0.04,
                        right: screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTasksHeading(
                            screenHeight, screenWidth, localizations),
                        _buildStatusChipsRow(
                            screenWidth, screenHeight, localizations, isDark),
                      ],
                    ),
                  ),

                  // Expanded Task List to take up remaining height
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(
                        bottom: screenWidth * 0.03,
                        left: screenWidth * 0.03,
                        right: screenWidth * 0.03,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade900 : Colors.white,
                      ),
                      child: RefreshIndicator(
                        onRefresh: _refreshList,
                        child: PagedListView<int, Task>(
                          pagingController: _pagingController,
                          builderDelegate: PagedChildBuilderDelegate<Task>(
                            itemBuilder: (context, task, index) => TaskCard(
                              title: task.activityName ?? localizations.noData,
                              description:
                                  task.description ?? localizations.noData,
                              status: task.status,
                            ),
                            firstPageProgressIndicatorBuilder: (_) =>
                                const Center(
                              child: CircularProgressIndicator(),
                            ),
                            newPageProgressIndicatorBuilder: (_) =>
                                const Center(
                              child: CircularProgressIndicator(),
                            ),
                            noItemsFoundIndicatorBuilder: (context) =>
                                EmptyData(message: localizations.noTask),
                            noMoreItemsIndicatorBuilder: (_) => Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.02),
                              child: EndOfListWidget(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return EmptyData(message: localizations.noTask);
          }
        },
      ),
    );
  }

  Widget _buildEventHeaderCard(double screenWidth, double screenHeight,
      bool isDark, Event event, AppLocalizations localizations) {
    return Card(
      color: isDark ? Colors.grey.shade900 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.only(bottom: screenHeight * 0.01),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    event.eventName ?? localizations.noData,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: screenHeight * 0.02,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    event.status ?? 'Scheduled',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: screenHeight * 0.016),
                  ),
                  backgroundColor: _getStatusColor(event.status),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.005),
            Divider(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                thickness: 1),
            SizedBox(height: screenHeight * 0.005),
            Row(
              children: [
                Icon(Icons.access_time, size: 20, color: Colors.blueGrey),
                SizedBox(width: 8),
                Text(
                  formatEventDateRange(event.fromDate, event.toDate),
                  style: TextStyle(
                    fontSize: screenHeight * 0.017,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Scheduled':
        return Colors.blueAccent;
      case 'In Progress':
        return Colors.orangeAccent;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildActivityDetails(double screenHeight, double screenWidth,
      Activity activity, AppLocalizations localizations, bool isDark) {
    return Card(
      color: isDark ? Colors.grey.shade900 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.only(bottom: screenHeight * 0.01),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    activity.activityName ?? localizations.noData,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenHeight * 0.02,
                      color: isDark
                          ? Colors.blueGrey.shade100
                          : Colors.blueGrey.shade900,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenHeight * 0.005,
                  ),
                  decoration: BoxDecoration(
                    color: Const.primaryGoldenColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    widget.group.groupName,
                    style: TextStyle(
                      fontSize: screenHeight * 0.016,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: screenHeight * 0.005),
            ExpandableText(
              activity.description ?? localizations.noData,
              expandText: localizations.showMore,
              collapseText: localizations.showLess,
              maxLines: 2,
              linkColor: Colors.blueAccent,
              style: TextStyle(
                fontSize: screenHeight * 0.016,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChipsRow(double screenWidth, double screenHeight,
      AppLocalizations localizations, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List<Widget>.generate(
            statusList.length,
            (int index) {
              var status = statusList[index];
              int taskCount = status['count'] ?? 0;

              return Padding(
                padding: EdgeInsets.only(right: screenWidth * 0.02),
                child: ChoiceChip(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  showCheckmark: false,
                  label: Text(
                    "${status['label']} ($taskCount)", // Display label with count
                    style: TextStyle(
                      color:
                          selectedIndex == index ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: screenHeight * 0.017,
                    ),
                  ),
                  selectedColor: status['backgroundColor'],
                  backgroundColor:
                      isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                  selected: selectedIndex == index,
                  onSelected: (bool selected) {
                    setState(() {
                      selectedIndex = index;
                      _filterTasksByStatus();
                    });
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTasksHeading(
      double screenHeight, double screenWidth, AppLocalizations localizations) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          localizations.task,
          style: TextStyle(
            fontSize: screenHeight * 0.025,
            fontWeight: FontWeight.w700,
          ),
        ),
        TextButton(
          onPressed: () {
            Get.to(() => UpdateProgress(tasks: _allTasks),
                id: 3, transition: Transition.rightToLeftWithFade);
          },
          style: TextButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text(
            localizations.updateProgress,
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        )
      ],
    );
  }
}
