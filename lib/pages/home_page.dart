import 'dart:async';
import 'dart:convert';

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
import 'package:shepherd_mo/models/activity.dart';
import 'package:shepherd_mo/models/event.dart';
import 'package:shepherd_mo/models/group.dart';
import 'package:shepherd_mo/models/group_role.dart';
import 'package:shepherd_mo/models/user.dart';
import 'package:shepherd_mo/pages/group_members_page.dart';
import 'package:shepherd_mo/pages/leader/create_event.dart';
import 'package:shepherd_mo/pages/leader/task_management_page.dart';
import 'package:shepherd_mo/pages/login_page.dart';
import 'package:shepherd_mo/pages/settings_page.dart';
import 'package:shepherd_mo/pages/task_page.dart';
import 'package:shepherd_mo/providers/ui_provider.dart';
import 'package:shepherd_mo/services/get_login.dart';
import 'package:shepherd_mo/utils/toast.dart';
import 'package:shepherd_mo/widgets/activity_card.dart';
import 'package:shepherd_mo/widgets/custom_appbar.dart';
import 'package:shepherd_mo/widgets/empty_data.dart';
import 'package:shepherd_mo/widgets/event_card.dart';
import 'package:shepherd_mo/widgets/organization_card.dart';
import 'package:shepherd_mo/widgets/profile_menu_widget.dart';
import 'package:shepherd_mo/widgets/progressHUD.dart';
import 'package:shepherd_mo/widgets/upcoming_card.dart';
import 'package:table_calendar/table_calendar.dart';
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
  Timer? _roleUpdateTimer;

  void _onTabTapped(int index) {
    if (controller.selectedIndex.value == index) {
      Get.offAllNamed(_tabsRoutes[index], id: index);
    } else {
      controller.selectedIndex.value = index;
    }
  }

  @override
  void dispose() {
    _roleUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    navigatorKeys = List.generate(
      tabs.length,
      (index) => GlobalKey<NavigatorState>(),
    );
    _startRoleUpdateTaskIfLoggedIn();
  }

  Future<void> _startRoleUpdateTaskIfLoggedIn() async {
    bool loggedIn = await isUserLoggedIn();
    ApiService apiService = ApiService();

    if (loggedIn) {
      // Fetch and update roles immediately
      await apiService.fetchAndCompareGroupRoles(null);
      await _updateAuthorizationStatus();

      // Set up periodic task every 5 seconds
      _roleUpdateTimer = Timer.periodic(Duration(minutes: 1), (timer) async {
        await apiService.fetchAndCompareGroupRoles(null);
        await _updateAuthorizationStatus();
        print('Fetched roles');
      });
    }
  }

  Future<void> _updateAuthorizationStatus() async {
    bool isAuthorized = await checkUserRoles();
    bool isLeader = await checkGroupUserRoles();
    print(isAuthorized);
    print(isLeader);
    Get.find<AuthorizationController>().updateAuthorizationStatus(isAuthorized);
    Get.find<AuthorizationController>()
        .updateGroupAuthorizationStatus(isLeader);
  }

  Future<bool> isUserLoggedIn() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    return token != null;
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UIProvider>(context);
    bool isDark = uiProvider.themeMode == ThemeMode.dark ||
        (uiProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final localizations = AppLocalizations.of(context)!;

    return Obx(
      () => Scaffold(
        appBar: CustomAppBar(
            screenWidth: MediaQuery.of(context).size.width,
            screenHeight: MediaQuery.of(context).size.height),
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
              text: localizations.home,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFEEC05C),
              ),
            ),
            GButton(
              icon: Icons.chat,
              iconActiveColor: const Color(0xFFEEC05C),
              text: localizations.message,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFEEC05C),
              ),
            ),
            GButton(
              icon: Icons.event,
              iconActiveColor: const Color(0xFFEEC05C),
              text: localizations.event,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFEEC05C),
              ),
            ),
            GButton(
              icon: Icons.wysiwyg,
              iconActiveColor: const Color(0xFFEEC05C),
              text: localizations.activity,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFEEC05C),
              ),
            ),
            GButton(
              icon: Icons.menu,
              iconActiveColor: const Color(0xFFEEC05C),
              text: localizations.menu,
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
        pageSize: 20,
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
    final localizations = AppLocalizations.of(context)!;

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
                  style: TextStyle(
                      fontSize: screenHeight * 0.025,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.group ?? 'Group',
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
                                    'Bạn đang ở trong ${groups.length} đoàn thể')),
                            SizedBox(height: screenHeight * 0.02),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: groups.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  var group = entry.value;

                                  // Set color based on index
                                  final cardColor = index % 2 == 0
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
                                      Get.to(() => GroupDetail(group: group),
                                          id: 0,
                                          transition:
                                              Transition.rightToLeftWithFade);
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
                    "${localizations.event} & ${localizations.activity}",
                    style: TextStyle(
                      fontSize: screenHeight * 0.03,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      UpcomingCard(
                        icon: Icon(Icons.event,
                            size: screenHeight * 0.09, color: Colors.black),
                        color: const Color(0xFFEEC05C),
                        title: localizations.upcomingEvents,
                        onCardPressed: () {
                          //View all Upcoming
                        },
                      ),
                      UpcomingCard(
                        icon: Icon(Icons.wysiwyg,
                            size: screenHeight * 0.09, color: Colors.black),
                        color: const Color(0xFFEEC05C),
                        title: localizations.upcomingActivities,
                        onCardPressed: () {
                          //View all Upcoming
                        },
                      ),
                    ],
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

  final localeController = Get.find<LocaleController>();
  final authorizationController = Get.find<AuthorizationController>();

  bool isLoading = true;
  Map<DateTime, List<Event>> eventsByDate = {};
  List<Event> selectedEvents = [];

  Future<void> fetchEvents() async {
    setState(() {
      isLoading = true;
    });
    try {
      final apiService = ApiService();
      eventsByDate = await apiService.fetchEventsCalendar(focusedDay.toString(),
          "", _calendarFormat == CalendarFormat.week ? 0 : 1, "false", "false");
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
    });
  }

  @override
  void initState() {
    super.initState();
    fetchEvents();
    _updateSelectedDayEvents();
  }

  @override
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
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      floatingActionButton: authorizationController.isAuthorized.value
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
          localizations.event,
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
                    fetchEvents();
                  }
                },
                // Calendar builders to customize markers
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isNotEmpty) {
                      return Container(
                        width: screenHeight * 0.021,
                        height: screenHeight * 0.021,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.red[700],
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${events.length}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenHeight * 0.011,
                            fontWeight: FontWeight.w700,
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
                    });
                    fetchEvents();
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
                  ? EmptyData(message: localizations.noEvent)
                  : ListView.builder(
                      itemCount: selectedEvents.length,
                      itemBuilder: (context, index) {
                        final event = selectedEvents[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          child: EventCard(
                              event: event,
                              screenHeight: screenHeight,
                              isDark: isDark,
                              screenWidth: screenWidth),
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
  int selectedIndex = -1;
  DateTime today = DateTime.now();
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  bool isLoading = true;
  Map<DateTime, List<Activity>> activitiesByDate = {};
  List<Activity> selectedActivities = [];
  final LocaleController localeController = Get.find<LocaleController>();
  final authorizationController = Get.find<AuthorizationController>();

  Future<List<GroupRole>>? userGroups;
  User? loginInfo;
  void _onDaySelected(DateTime day, DateTime focusedDay) {
    if (mounted) {
      setState(() {
        selectedDay = day;
        this.focusedDay = focusedDay;
        _updateSelectedDayActivities();
      });
    }
  }

  Future<void> initializeData() async {
    setState(() {
      isLoading = true;
    });
    userGroups = loadUserGroupInfo();
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
        pageSize: 20,
        userId: loginInfo!.id,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<GroupRole>> loadUserGroupInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userGroups = prefs.getString("loginUserGroups");
    List<GroupRole> loginUserGroupsList = [];
    if (userGroups != null) {
      List<dynamic> decodedJson = jsonDecode(userGroups);
      loginUserGroupsList = decodedJson
          .map((item) => GroupRole.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return loginUserGroupsList;
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

  Future<void> fetchActivities() async {
    setState(() {
      isLoading = true;
    });
    try {
      final apiService = ApiService();
      activitiesByDate = await apiService.fetchActivitiesCalendar(
          focusedDay.toString(),
          selectedOrganization,
          _calendarFormat == CalendarFormat.week ? 0 : 1,
          "true",
          "false");
    } finally {
      setState(() {
        isLoading = false;
      });
      _updateSelectedDayActivities();
    }
  }

  void _updateSelectedDayActivities() {
    setState(() {
      final date =
          DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

      selectedActivities = activitiesByDate[date] ?? [];
    });
  }

  @override
  void initState() {
    super.initState();
    initializeData();
    fetchActivities();
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          localizations.activity,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          children: [
            // Dropdown Menu with FutureBuilder
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(
                    color:
                        isDark ? Colors.orangeAccent : Colors.orange.shade600,
                    width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FutureBuilder<List<GroupRole>>(
                future: userGroups, // Replace with your method to fetch groups
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text(localizations.noParticipatedGroup);
                  } else {
                    final userGroups = snapshot.data!;
                    return DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: Text(localizations.allCurrentlyUserOrganizations),
                        value: selectedOrganization,
                        isExpanded: true,
                        focusColor: Colors.orange,
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: screenHeight * 0.025,
                        dropdownColor: isDark ? Colors.black : Colors.white,
                        style: TextStyle(
                          fontSize: screenHeight * 0.016,
                          fontWeight: FontWeight.bold,
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: "All", // Special value for "All" option
                            child: Row(
                              children: [
                                const Icon(Icons.group),
                                SizedBox(width: screenWidth * 0.03),
                                Text(
                                  localizations.allCurrentlyUserOrganizations,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...userGroups.map((GroupRole userGroup) {
                            return DropdownMenuItem<String>(
                              value: userGroup.groupId,
                              child: Row(
                                children: [
                                  const Icon(Icons.group),
                                  SizedBox(width: screenWidth * 0.03),
                                  Text(
                                    userGroup.groupName,
                                    style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedOrganization =
                                newValue == "All" ? null : newValue;
                            isLoading = true;
                          });
                          fetchActivities();
                        },
                      ),
                    );
                  }
                },
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            // Horizontal scrolling with TableCalendar (or other widget)
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
                  return activitiesByDate[date] ?? [];
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
                    fetchActivities();
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
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenHeight * 0.011,
                            fontWeight: FontWeight.w700,
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
                onHeaderTapped: (focusedDay) {
                  if (mounted) {
                    setState(() {
                      selectedDay = today;
                      focusedDay = today;
                    });
                    fetchActivities();
                  }
                },

                // Handle page changes (e.g., scrolling through months)
                onPageChanged: (newFocusedDay) {
                  // Only update the focusedDay when switching months, do not reset selectedDay
                  setState(() {
                    focusedDay =
                        newFocusedDay; // Update the focused day without affecting selectedDay
                  });
                  fetchActivities();
                },
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            // Expanded ListView for Activities with no glow

            Expanded(
              child: selectedActivities.isEmpty
                  ? EmptyData(message: localizations.noActivity)
                  : ListView.builder(
                      itemCount: selectedActivities.length,
                      itemBuilder: (context, index) {
                        final activity = selectedActivities[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          child: ActivityCard(
                            title: activity.activityName!,
                            startDate: activity.startTime!,
                            endDate: activity.endTime!,
                            status: activity.status!,
                            onTap: () async {
                              // Check if an organization is selected
                              if (selectedOrganization == null ||
                                  selectedOrganization!.isEmpty) {
                                // Show a dialog prompting the user to select an organization
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Select Organization"),
                                      content: Text(
                                          "Please choose an organization to continue."),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: Text("OK"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                return; // Exit the onTap function if no organization is selected
                              }

                              try {
                                // Await the userGroups Future to get the actual list
                                final userGroupList = await userGroups;

                                // Check the user's role in the selected organization
                                final userGroup = userGroupList!.firstWhere(
                                  (group) =>
                                      group.groupId == selectedOrganization,
                                );

                                final isLeader = userGroup.roleName ==
                                        "Trưởng nhóm" ||
                                    userGroup.roleName ==
                                        "Thành viên"; // Adjust role name check as needed
                                Get.to(
                                  () => isLeader
                                      ? TaskManagementPage(
                                          activityId: activity.id,
                                          activityName: activity.activityName!,
                                          group: userGroup)
                                      : TaskPage(
                                          activityId: activity.id,
                                          activityName: activity.activityName!,
                                          group: userGroup),
                                  id: 3,
                                  transition: Transition.rightToLeftWithFade,
                                );
                              } catch (e) {
                                // Handle potential errors
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Error"),
                                      content: Text(
                                          "Failed to load user groups: $e"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: Text("OK"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
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
                  prefs.remove('loginUserGroups');

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
