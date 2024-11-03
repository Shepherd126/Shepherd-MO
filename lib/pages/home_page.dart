import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shepherd_mo/api/api_service.dart';
import 'package:shepherd_mo/controller/controller.dart';
import 'package:shepherd_mo/models/event.dart';
import 'package:shepherd_mo/models/group.dart';
import 'package:shepherd_mo/models/task.dart';
import 'package:shepherd_mo/models/user.dart';
import 'package:shepherd_mo/pages/event_detail.dart';
import 'package:shepherd_mo/pages/leader/create_event.dart';
import 'package:shepherd_mo/pages/leader/task_management_page.dart';
import 'package:shepherd_mo/pages/login_page.dart';
import 'package:shepherd_mo/pages/settings_page.dart';
import 'package:shepherd_mo/pages/task_page.dart';
import 'package:shepherd_mo/providers/provider.dart';
import 'package:shepherd_mo/services/get_login.dart';
import 'package:shepherd_mo/utils/toast.dart';
import 'package:shepherd_mo/widgets/activity_card.dart';
import 'package:shepherd_mo/widgets/gradient_text.dart';
import 'package:shepherd_mo/widgets/organization_card.dart';
import 'package:shepherd_mo/widgets/profile_menu_widget.dart';
import 'package:shepherd_mo/widgets/progressHUD.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  final BottomNavController controller = Get.put(BottomNavController());

  final List<String> _tabsRoutes = [
    '/home',
    '/message',
    '/schedule',
    '/activities',
    '/menu',
  ];

  final List<Widget> tabs = [
    const HomeTab(),
    const MessageTab(),
    const ScheduleTab(),
    const ActivitiesTab(),
    const MenuTab()
  ];

  late List<GlobalKey<NavigatorState>> navigatorKeys;

  void _onTabTapped(int index) {
    if (controller.selectedIndex.value == index) {
      Get.offAllNamed(_tabsRoutes[index], id: index);
    } else {
      controller.selectedIndex.value = index;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    navigatorKeys = List.generate(
      tabs.length,
      (index) => GlobalKey<NavigatorState>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UIProvider>(context);
    bool isDark = uiProvider.themeMode == ThemeMode.dark ||
        (uiProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Obx(
      () => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.shade300,
          forceMaterialTransparency: true,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 1),
              child: Stack(
                children: <Widget>[
                  SizedBox(
                    width: screenWidth * 0.15,
                    height: screenWidth * 0.15,
                    child: IconButton(
                      onPressed: () {
                        // Handle notification button press
                      },
                      icon: Icon(
                        Icons.notifications_none,
                        size: screenWidth * 0.075,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 13,
                    top: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      constraints: BoxConstraints(
                        minWidth: screenWidth * 0.035,
                        minHeight: screenWidth * 0.035,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          title: Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                child: Image.asset(
                  'assets/images/shepherd.png',
                  scale: screenHeight * 0.015,
                ),
              ),
              GradientText(
                'Shepherd',
                style: TextStyle(
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800],
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.2, 0.8],
                  colors: [
                    Colors.orange.shade900,
                    Colors.orange.shade600,
                  ],
                ),
              ),
            ],
          ),
        ),
        body: IndexedStack(
          index: controller.selectedIndex.value,
          children: List.generate(
            tabs.length,
            (index) => _buildNestedNavigator(index),
          ),
        ),
        bottomNavigationBar: GNav(
          backgroundColor: const Color(0xFFEEC05C),
          color: isDark ? Colors.black : Colors.white,
          activeColor: Colors.blue,
          tabBackgroundColor: isDark ? Colors.black : Colors.grey.shade100,
          gap: screenWidth * 0.03,
          selectedIndex: controller.selectedIndex.value,
          onTabChange: _onTabTapped,
          padding: EdgeInsets.all(screenWidth * 0.04),
          tabs: [
            GButton(
              icon: Icons.home,
              iconActiveColor: const Color(0xFFEEC05C),
              text: AppLocalizations.of(context)!.home,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFEEC05C),
              ),
            ),
            GButton(
              icon: Icons.chat,
              iconActiveColor: const Color(0xFFEEC05C),
              text: AppLocalizations.of(context)!.message,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFEEC05C),
              ),
            ),
            GButton(
              icon: Icons.schedule,
              iconActiveColor: const Color(0xFFEEC05C),
              text: AppLocalizations.of(context)!.schedule,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFEEC05C),
              ),
            ),
            GButton(
              icon: Icons.wysiwyg,
              iconActiveColor: const Color(0xFFEEC05C),
              text: AppLocalizations.of(context)!.activity,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFEEC05C),
              ),
            ),
            GButton(
              icon: Icons.menu,
              iconActiveColor: const Color(0xFFEEC05C),
              text: AppLocalizations.of(context)!.menu,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFEEC05C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitialRouteForTab(int index) {
    return _tabsRoutes[index];
  }

  Widget _buildNestedNavigator(int index) {
    return Navigator(
      key: Get.nestedKey(index),
      initialRoute: _getInitialRouteForTab(index),
      onGenerateRoute: (RouteSettings settings) {
        Widget page;
        switch (settings.name) {
          case '/home':
            page = const HomeTab();
            break;
          case '/message':
            page = const MessageTab();
            break;
          case '/schedule':
            page = const ScheduleTab();
            break;
          case '/activities':
            page = const ActivitiesTab();
            break;
          case '/menu':
            page = const MenuTab();
            break;
          default:
            page = const HomeTab();
        }
        return GetPageRoute(
          page: () => page,
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 1000),
        );
      },
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  User? loginInfo;
  bool isLoading = false;

  Future<List<Group>>? groups;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    setState(() {
      isLoading = true;
    });

    await loadUserInfo(); // Wait for loadUserInfo to complete
    groups = fetchGroups(); // Now, load groups with user info
  }

  Future<List<Group>> fetchGroups() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Assuming the ApiService fetchGroups function requires parameters
      final apiService = ApiService();
      return await apiService.fetchGroups(
        searchKey: '',
        pageNumber: 1,
        pageSize: 5,
        userId: loginInfo!.id,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadUserInfo() async {
    final user = await getLoginInfoFromPrefs();

    if (user != null) {
      setState(() {
        loginInfo = user;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
        inAsyncCall: isLoading, // Show ProgressHUD overlay when loading
        opacity: 0.3,
        child: _uiSetup(context));
  }

  Widget _uiSetup(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final now = DateTime.now();

    // Ensure loginInfo is not null before using it
    final String name = loginInfo?.name ?? "User";
    final greetingMessage = getGreetingMessage(now.hour, name);

    // Access provider and check for null or default values
    final uiProvider = Provider.of<UIProvider>(context, listen: false);
    final bool isDark = uiProvider.themeMode == ThemeMode.dark ||
        (uiProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: Text(
                  greetingMessage,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.group ?? 'Group',
                    style: TextStyle(
                      fontSize: screenHeight * 0.03,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FutureBuilder<List<Group>>(
                    future:
                        groups, // Ensure `groups` is initialized as a Future
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "${snapshot.error}",
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text("No groups available"),
                        );
                      } else {
                        final groups = snapshot.data!;
                        return Column(
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                    'Bạn đang trong ${groups.length} đoàn thể')),
                            SizedBox(height: screenHeight * 0.02),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: groups.map((group) {
                                  final cardColor = group.priority
                                      ? Colors.lightBlue.shade200
                                      : Colors.purple.shade200;

                                  return OrganizationCard(
                                    color: cardColor,
                                    title: group.groupName,
                                    membersCount: group
                                        .memberCount, // Replace with actual member count if available
                                    onDetailsPressed: () {
                                      print(
                                          "Details for ${group.groupName} pressed");
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Text(
                    AppLocalizations.of(context)!.upcomingEvent,
                    style: TextStyle(
                      fontSize: screenHeight * 0.03,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getGreetingMessage(int hour, String name) {
    if (hour >= 3 && hour < 11) {
      return '${AppLocalizations.of(context)!.morning}, $name';
    } else if (hour >= 11 && hour < 16) {
      return '${AppLocalizations.of(context)!.afternoon}, $name';
    } else if (hour >= 16 && hour < 18) {
      return '${AppLocalizations.of(context)!.evening}, $name';
    } else {
      return '${AppLocalizations.of(context)!.night}, $name';
    }
  }
}

class MessageTab extends StatefulWidget {
  const MessageTab({super.key});
  @override
  State<MessageTab> createState() => _MessageTabState();
}

class _MessageTabState extends State<MessageTab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({super.key});
  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  DateTime today = DateTime.now();
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool headerTappedCalled = false;

  final LocaleController localeController = Get.find();
  bool isLoading = true;
  Map<DateTime, List<Event>> eventsByDate = {};
  List<Event> selectedEvents = [];

  Future<void> fetchEvents() async {
    setState(() {
      isLoading = true;
    });
    try {
      final apiService = ApiService();
      eventsByDate = await apiService.fetchEventsCalendar(
          focusedDay.toString(), "", 1, "false", "false");
    } finally {
      setState(() {
        isLoading = false;
      });
      _updateSelectedDayEvents();
    }
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    if (mounted) {
      setState(() {
        selectedDay = day;
        this.focusedDay = focusedDay;
        _updateSelectedDayEvents();
      });
    }
  }

  void _updateSelectedDayEvents() {
    setState(() {
      final date =
          DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

      selectedEvents = eventsByDate[date] ?? [];
      print(selectedEvents);
    });
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('vi');
    fetchEvents();
    _updateSelectedDayEvents();
  }

  Widget build(BuildContext context) {
    return ProgressHUD(
        inAsyncCall: isLoading, opacity: 0.3, child: _uiSetup(context));
  }

  Widget _uiSetup(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final uiProvider = Provider.of<UIProvider>(context);
    bool isDark = uiProvider.themeMode == ThemeMode.dark ||
        (uiProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    bool isLeader = true;
    final String locale = Localizations.localeOf(context).toLanguageTag();

    return Scaffold(
      floatingActionButton: isLeader
          ? FloatingActionButton(
              heroTag: 'schedule',
              onPressed: () {
                Get.to(() => const CreateEditEventPage(),
                    id: 2, transition: Transition.rightToLeftWithFade);
              },
              backgroundColor: Colors.orange,
              shape: const CircleBorder(),
              child: const Icon(Icons.add),
            )
          : null,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.event,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Column(
          children: [
            Obx(
              () => TableCalendar(
                locale: localeController.currentLocale.languageCode,
                rowHeight: screenHeight * 0.05,
                focusedDay: focusedDay,
                firstDay: DateTime.utc(2020, 01, 01),
                lastDay: DateTime.utc(2040, 12, 31),
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarFormat: _calendarFormat,
                availableCalendarFormats:
                    localeController.availableCalendarFormats,
                availableGestures: AvailableGestures.all,
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  titleTextFormatter: (date, locale) {
                    if (locale == 'vi') {
                      final String formattedDate =
                          DateFormat.yMMMM(locale).format(date);
                      List<String> parts = formattedDate.split(' ');

                      if (parts.length > 3) {
                        parts[0] =
                            parts[0][0].toUpperCase() + parts[0].substring(1);
                        parts[2] =
                            parts[2][0].toUpperCase() + parts[2].substring(1);
                      }

                      return parts.join(' ');
                    } else {
                      return DateFormat.yMMMM(locale).format(date);
                    }
                  },
                ),
                eventLoader: (day) {
                  final date = DateTime(day.year, day.month, day.day);
                  return eventsByDate[date] ?? [];
                },

                // Customizing Calendar Appearance
                calendarStyle: CalendarStyle(
                  todayDecoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.orange.shade800,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: const TextStyle(
                    color: Colors.white,
                  ),
                  defaultTextStyle: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  weekendTextStyle: const TextStyle(
                    color: Colors.red,
                  ),
                  outsideTextStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                onFormatChanged: (format) {
                  if (_calendarFormat != format && mounted) {
                    setState(() {
                      _calendarFormat = format;
                      focusedDay = selectedDay;
                    });
                  }
                },
                // Calendar builders to customize markers
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isNotEmpty) {
                      return Container(
                        width: 15,
                        height: 15,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.red[700],
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${events.length}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),

                // Handle day selection
                selectedDayPredicate: (day) => isSameDay(day, selectedDay),
                onDaySelected: _onDaySelected,

                // When the calendar header is tapped
                onHeaderTapped: (day) {
                  if (mounted) {
                    setState(() {
                      selectedDay = today;
                      focusedDay = today;
                      _updateSelectedDayEvents();
                    });
                  }
                },

                // Handle page changes (e.g., scrolling through months)
                onPageChanged: (newFocusedDay) {
                  setState(() {
                    focusedDay =
                        newFocusedDay; // Update the focused day without affecting selectedDay
                  });
                  fetchEvents();
                },
              ),
            ),
            Expanded(
              child: selectedEvents.isEmpty
                  ? Center(child: Text(AppLocalizations.of(context)!.noEvent))
                  : ListView.builder(
                      itemCount: selectedEvents.length,
                      itemBuilder: (context, index) {
                        final event = selectedEvents[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          child: Card(
                            elevation: 2.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ExpansionTile(
                              title: Text(
                                event.eventName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: screenHeight * 0.019,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.event, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                          "${AppLocalizations.of(context)!.start}: ${DateFormat('dd/MM/yyyy').format(event.fromDate!)} | ${DateFormat('HH:mm').format(event.fromDate!)}"),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.event_available, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                          "${AppLocalizations.of(context)!.end}: ${DateFormat('dd/MM/yyyy').format(event.toDate!)} | ${DateFormat('HH:mm').format(event.toDate!)}"),
                                    ],
                                  ),
                                ],
                              ),
                              leading:
                                  const Icon(Icons.event, color: Colors.orange),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${event.description}",
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.grey[300]
                                              : Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Status: ${event.status}",
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      if (event.isPublic != null)
                                        Text("Public: ${event.isPublic}"),
                                      if (event.totalCost != null)
                                        Text("Total Cost: ${event.totalCost}"),
                                      if (event.approvedBy != null)
                                        Text(
                                            "Approved By: ${event.approvedBy}"),
                                      if (event.approvalDate != null)
                                        Text(
                                            "Approval Date: ${DateFormat('MMM d, yyyy').format(event.approvalDate!)}"),
                                      // Action buttons
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              Get.to(
                                                  () => EventDetailsPage(
                                                      eventId: event.id!),
                                                  id: 2,
                                                  transition: Transition
                                                      .rightToLeftWithFade);
                                            },
                                            child: Text(
                                                AppLocalizations.of(context)!
                                                    .details),
                                          ),
                                          isLeader
                                              ? Row(
                                                  children: [
                                                    SizedBox(
                                                        width:
                                                            screenWidth * 0.02),
                                                    TextButton(
                                                      onPressed: () {
                                                        // Handle edit logic
                                                      },
                                                      child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .edit),
                                                    )
                                                  ],
                                                )
                                              : SizedBox.shrink()
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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

class ActivitiesTab extends StatefulWidget {
  const ActivitiesTab({super.key});

  @override
  State<ActivitiesTab> createState() => _ActivitiesTabState();
}

class _ActivitiesTabState extends State<ActivitiesTab> {
  String? selectedOrganization;
  final List<String> status = ['To Do', 'In Progress', 'Review', 'Done'];
  int selectedIndex = -1;
  DateTime today = DateTime.now();
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  final LocaleController localeController = Get.find<LocaleController>();
  bool isLeader = true;

  final List<String> organizations = [
    'Ban Thường Vụ',
    'Ban Ca Đoàn',
    'Ban Tương Tế',
    'Ban Phụng Vụ',
  ];

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

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    if (mounted) {
      setState(() {
        selectedDay = day;
      });
    }
  }

  void onTapActivity() {
    Get.to(() => isLeader ? const TaskManagementPage() : const TaskPage(),
        id: 3, transition: Transition.rightToLeftWithFade);
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
      floatingActionButton: isLeader
          ? FloatingActionButton(
              heroTag: 'activity',
              onPressed: () {
                // Navigating
              },
              backgroundColor: Colors.orange,
              shape: const CircleBorder(),
              child: const Icon(Icons.add),
            )
          : null,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          AppLocalizations.of(context)!.activity,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        forceMaterialTransparency: true,
        elevation: 0, // Remove the shadow effect
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          children: [
            // Dropdown Menu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: const Text("Choose your organization"),
                  value: selectedOrganization,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down,
                      color: Colors.blueAccent),
                  iconSize: 30,
                  dropdownColor: Colors.white,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  items: organizations.map((String organization) {
                    return DropdownMenuItem<String>(
                      value: organization,
                      child: Row(
                        children: [
                          const Icon(Icons.group, color: Colors.blue),
                          const SizedBox(width: 10),
                          Text(organization),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedOrganization = newValue;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            // Horizontal scrolling
            Obx(
              () => TableCalendar(
                locale: localeController.currentLocale.languageCode,
                rowHeight: screenHeight * 0.05,
                focusedDay: focusedDay,
                firstDay: DateTime.utc(2020, 01, 01),
                lastDay: DateTime.utc(2040, 12, 31),
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarFormat: _calendarFormat,
                availableCalendarFormats:
                    localeController.availableCalendarFormats,
                availableGestures: AvailableGestures.all,
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  titleTextFormatter: (date, locale) {
                    if (locale == 'vi') {
                      final String formattedDate =
                          DateFormat.yMMMM(locale).format(date);
                      List<String> parts = formattedDate.split(' ');

                      if (parts.length > 3) {
                        parts[0] =
                            parts[0][0].toUpperCase() + parts[0].substring(1);
                        parts[2] =
                            parts[2][0].toUpperCase() + parts[2].substring(1);
                      }

                      return parts.join(' ');
                    } else {
                      return DateFormat.yMMMM(locale).format(date);
                    }
                  },
                ),

                // Customizing Calendar Appearance
                calendarStyle: CalendarStyle(
                  todayDecoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.orange.shade800,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: const TextStyle(
                    color: Colors.white,
                  ),
                  defaultTextStyle: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  weekendTextStyle: const TextStyle(
                    color: Colors.red,
                  ),
                  outsideTextStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                onFormatChanged: (format) {
                  if (_calendarFormat != format && mounted) {
                    setState(() {
                      _calendarFormat = format;
                      focusedDay = selectedDay;
                    });
                  }
                },

                // Calendar builders to customize markers
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isNotEmpty) {
                      return Container(
                        width: 15,
                        height: 15,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${events.length}',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),

                // Handle day selection
                selectedDayPredicate: (day) => isSameDay(day, selectedDay),
                onDaySelected: _onDaySelected,

                // When the calendar header is tapped
                onHeaderTapped: (focusedDay) {
                  if (mounted) {
                    setState(() {
                      selectedDay = today;
                      focusedDay = today;
                    });
                  }
                },

                // Handle page changes (e.g., scrolling through months)
                onPageChanged: (newFocusedDay) {
                  // Only update the focusedDay when switching months, do not reset selectedDay
                  setState(() {
                    focusedDay =
                        newFocusedDay; // Update the focused day without affecting selectedDay
                  });
                },
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            // Expanded ListView for Activities with no glow
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  ActivityCard(
                    title: 'Activity 1',
                    startDate: '23/10/2024',
                    endDate: '23/10/2024',
                    status: 'Completed',
                    onTap: () {
                      onTapActivity();
                    },
                  ),
                  ActivityCard(
                    title: 'Activity 2',
                    startDate: '24/10/2024',
                    endDate: '25/10/2024',
                    status: 'In Progress',
                    onTap: onTapActivity,
                  ),
                  ActivityCard(
                    title: 'Activity 3',
                    startDate: '25/10/2024',
                    endDate: '26/10/2024',
                    status: 'Pending',
                    onTap: onTapActivity,
                  ),
                  ActivityCard(
                    title: 'Activity 4',
                    startDate: '28/10/2024',
                    endDate: '29/10/2024',
                    status: 'Completed',
                    onTap: onTapActivity,
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

class MenuTab extends StatefulWidget {
  const MenuTab({super.key});

  @override
  State<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
  @override
  Widget build(BuildContext context) {
    ImageProvider<Object> backgroundImage =
        const AssetImage('assets/images/user.png');
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('Menu', style: Theme.of(context).textTheme.headlineMedium),
        actions: const [],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: backgroundImage,
                      backgroundColor: Colors.orange,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.orange,
                        ),
                        child: const Icon(
                          LineAwesomeIcons.pencil_alt_solid,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              const Text('Name',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text('Email', style: TextStyle(fontSize: 16)),
              SizedBox(height: screenHeight * 0.02),
              SizedBox(
                width: screenWidth * 0.45,
                height: screenHeight * 0.06,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEEC05C),
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              const Divider(
                thickness: 0.1,
              ),
              const SizedBox(height: 5),
              ProfileMenuWidget(
                title: 'Change Password',
                icon: LineAwesomeIcons.lock_open_solid,
                iconColor: const Color(0xFFEEC05C),
                onTap: () {},
              ),
              ProfileMenuWidget(
                title: 'Settings',
                icon: LineAwesomeIcons.cog_solid,
                iconColor: const Color(0xFFEEC05C),
                onTap: () {
                  Get.to(() => const SettingsPage(),
                      id: 4, transition: Transition.rightToLeftWithFade);
                },
              ),
              ProfileMenuWidget(
                title: 'Log out',
                icon: LineAwesomeIcons.sign_out_alt_solid,
                iconColor: const Color(0xFFEEC05C),
                textColor: Colors.red,
                endIcon: false,
                onTap: () async {
                  const storage = FlutterSecureStorage();
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await storage.delete(key: 'token');
                  prefs.remove('loginInfo');
                  showToast("Logged Out Successfully");
                  Get.off(const LoginPage());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
