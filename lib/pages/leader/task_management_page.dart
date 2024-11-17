import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shepherd_mo/api/api_service.dart';
import 'package:shepherd_mo/constant/constant.dart';
import 'package:shepherd_mo/controller/controller.dart';
import 'package:shepherd_mo/formatter/status_language.dart';
import 'package:shepherd_mo/models/activity.dart';
import 'package:shepherd_mo/models/event.dart';
import 'package:shepherd_mo/models/group_role.dart';
import 'package:shepherd_mo/models/task.dart';
import 'package:shepherd_mo/pages/leader/create_task.dart';
import 'package:shepherd_mo/pages/update_progress.dart';
import 'package:shepherd_mo/providers/ui_provider.dart';
import 'package:shepherd_mo/widgets/empty_data.dart';
import 'package:shepherd_mo/widgets/end_of_line.dart';
import 'package:shepherd_mo/widgets/progressHUD.dart';
import 'package:shepherd_mo/widgets/task_card.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TaskManagementPage extends StatefulWidget {
  final String activityId;
  final String activityName;
  final GroupRole group;
  const TaskManagementPage(
      {super.key,
      required this.activityId,
      required this.activityName,
      required this.group});

  @override
  State<TaskManagementPage> createState() => _TaskManagementPageState();
}

class _TaskManagementPageState extends State<TaskManagementPage> {
  int selectedIndex = 0;
  final PagingController<int, Task> _pagingController =
      PagingController(firstPageKey: 1);
  final int _pageSize = 10;
  final taskController = Get.find<TaskController>();
  final GlobalKey<RefreshIndicatorState> taskRefreshKey =
      GlobalKey<RefreshIndicatorState>();

  String? eventId;
  Future<Map<String, dynamic>>? _initialData;
  List<Map<String, dynamic>> statusList = [];
  List<Task> _allTasks = [];
  List<ChartData> chartData = [];
  Activity? activity;
  Event? event;
  bool isLoading = false;
  List<String> users = ['Nguyễn Văn A', 'Nguyễn Thị B', 'Trần Văn C'];
  void onSubmit(String name, String description, String user) {}

  @override
  void initState() {
    super.initState();
    _initialData = fetchData();
    _pagingController.addPageRequestListener((pageKey) {
      if (eventId != null) {
        _fetchTasks(pageKey);
      }
    });
    _initializeStatusList();
  }

  void _initializeStatusList() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final localizations = AppLocalizations.of(context)!;
      setState(() {
        statusList = [
          {
            'label': localizations.all,
            'backgroundColor': Const.primaryGoldenColor
          },
          {'label': localizations.draft, 'backgroundColor': Colors.amber[200]},
          {
            'label': localizations.pending,
            'backgroundColor': Colors.yellow[700]
          },
          {'label': localizations.toDo, 'backgroundColor': Colors.blueAccent},
          {
            'label': localizations.inProgress,
            'backgroundColor': Colors.orange[400]
          },
          {
            'label': localizations.review,
            'backgroundColor': Colors.deepOrange[600]
          },
          {'label': localizations.done, 'backgroundColor': Colors.green[600]},
        ];
      });
    });
  }

  // Listen to locale changes to update statusList
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeStatusList();
  }

  Future<Map<String, dynamic>> fetchData() async {
    ApiService apiService = ApiService();
    final results =
        await apiService.fetchActivities(searchKey: widget.activityId) ?? [];
    final data = results.first;

    setState(() {
      eventId = data['event']['id'];
      activity = Activity.fromJson(data);
      event = Event.fromJson(data['event']);
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

    try {
      final newTasks = await apiService.fetchTasks(
        searchKey: '',
        pageNumber: pageKey,
        pageSize: _pageSize,
        groupId: widget.group.groupId,
        activityId: widget.activityId,
        eventId: eventId,
        status: selectedStatus,
      );

      if (selectedIndex == 0) {
        _allTasks = newTasks;
        _updateTaskCounts();
      } else {
        _updateTaskCounts(); // Keep task counts based on _allTasks
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
    final localizations = AppLocalizations.of(context)!;

    final taskCounts = {
      localizations.all: _allTasks.length,
      localizations.draft:
          _allTasks.where((task) => task.status == 'Bản nháp').length,
      localizations.pending:
          _allTasks.where((task) => task.status == 'Đang duyệt').length,
      localizations.toDo:
          _allTasks.where((task) => task.status == 'Việc cần làm').length,
      localizations.inProgress:
          _allTasks.where((task) => task.status == 'Đang thực hiện').length,
      localizations.review:
          _allTasks.where((task) => task.status == 'Xem xét').length,
      localizations.done:
          _allTasks.where((task) => task.status == 'Đã hoàn thành').length,
    };

    setState(() {
      chartData = [
        ChartData(localizations.toDo, taskCounts[localizations.toDo] ?? 0,
            Colors.blueAccent),
        ChartData(localizations.inProgress,
            taskCounts[localizations.inProgress] ?? 0, Colors.orangeAccent),
        ChartData(localizations.review, taskCounts[localizations.review] ?? 0,
            Colors.redAccent),
        ChartData(localizations.done, taskCounts[localizations.done] ?? 0,
            Colors.green),
      ];
      for (var status in statusList) {
        status['count'] = taskCounts[status['label']] ?? 0;
      }
    });
  }

  int _calculateCompletionPercentage() {
    int totalTasks = _allTasks.length;
    int doneTasks =
        _allTasks.where((task) => task.status == 'Đã hoàn thành').length;
    return totalTasks > 0 ? ((doneTasks / totalTasks) * 100).round() : 0;
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
    return ProgressHUD(
        inAsyncCall: isLoading, opacity: 0.3, child: _uiSetup(context));
  }

  Widget _uiSetup(BuildContext context) {
    final uiProvider = Provider.of<UIProvider>(context);
    bool isDark = uiProvider.themeMode == ThemeMode.dark ||
        (uiProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    final localizations = AppLocalizations.of(context)!;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          localizations.task,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
        elevation: 4,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'task',
        onPressed: () {
          if (activity != null) {
            Get.to(
              () => CreateEditTaskPage(
                  activityId: widget.activityId,
                  activityName: widget.activityName,
                  group: widget.group),
              id: 3,
              transition: Transition.rightToLeftWithFade,
            );
          }
        },
        backgroundColor: Colors.orange,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
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
                      child: Obx(() {
                        if (taskController.shouldRefresh.value) {
                          _refreshList();
                          taskController.setShouldRefresh(false);
                        }
                        return RefreshIndicator(
                          displacement: 10,
                          key: taskRefreshKey,
                          onRefresh: _refreshList,
                          child: PagedListView<int, Task>(
                            pagingController: _pagingController,
                            builderDelegate: PagedChildBuilderDelegate<Task>(
                              itemBuilder: (context, task, index) => TaskCard(
                                title: task.title ?? localizations.noData,
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
                        );
                      }),
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
    String? eventStatus = getEventStatus(event.status, localizations);
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
                    eventStatus ?? localizations.noData,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: screenHeight * 0.015),
                  ),
                  backgroundColor: _getStatusColor(eventStatus),
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
            _allTasks.isNotEmpty
                ? SizedBox(
                    height: screenHeight * 0.18,
                    child: ClipRect(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: SfCircularChart(
                          legend: const Legend(
                              isVisible: true, position: LegendPosition.right),
                          series: <CircularSeries>[
                            PieSeries<ChartData, String>(
                              dataSource: chartData,
                              pointColorMapper: (ChartData data, _) =>
                                  data.color,
                              xValueMapper: (ChartData data, _) => data.status,
                              yValueMapper: (ChartData data, _) => data.value,
                              dataLabelSettings: DataLabelSettings(
                                isVisible: true,
                                showZeroValue: false,
                                textStyle: TextStyle(
                                    fontSize: screenHeight * 0.016,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink()
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Đang duyệt':
        return Colors.blueGrey;
      case 'Được thông qua':
        return Colors.green;
      case 'Không được thông qua':
        return Colors.red;
      case 'Đang diễn ra':
        return Colors.orangeAccent;
      case 'Quá hạn':
        return Colors.deepOrange;
      case 'Chưa bắt đầu':
        return Colors.lightBlueAccent;
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
                    color: Colors.blue,
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
                    "${status['label']} ($taskCount)",
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
              fontWeight: FontWeight.w600,
            ),
          ),
        )
      ],
    );
  }
}

class ChartData {
  ChartData(this.status, this.value, this.color);
  final String status;
  final int value;
  final Color color;
}
