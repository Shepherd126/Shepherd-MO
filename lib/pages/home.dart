import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shepherd_mo/controller/controller.dart';
import 'package:shepherd_mo/pages/settings.dart';
import 'package:shepherd_mo/providers/provider.dart';
import 'package:shepherd_mo/widgets/activity_card.dart';
import 'package:shepherd_mo/widgets/gradient_text.dart';
import 'package:shepherd_mo/widgets/organization_card.dart';
import 'package:shepherd_mo/widgets/profile_menu_widget.dart';
import 'package:shepherd_mo/widgets/status_button.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

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

  void _onTabTapped(int index) {
    controller.changeTabIndex(index);
    Get.offAllNamed(_tabsRoutes[index], id: index);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UIProvider>(context);
    bool isDark = uiProvider.themeMode == ThemeMode.dark ||
        (uiProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Obx(() => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.grey.shade300,
            forceMaterialTransparency: true,
            leading: Padding(
              padding: EdgeInsets.only(left: screenWidth * 0.02),
              child: Image.asset(
                'assets/images/shepherd.png',
                scale: screenWidth * 0.02,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 1),
                child: Stack(
                  children: <Widget>[
                    Container(
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
            title: GradientText(
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
            tabs: const [
              GButton(
                icon: Icons.home,
                iconActiveColor: Color(0xFFEEC05C),
                text: 'Home',
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEEC05C),
                ),
              ),
              GButton(
                icon: Icons.chat,
                iconActiveColor: Color(0xFFEEC05C),
                text: 'Message',
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEEC05C),
                ),
              ),
              GButton(
                icon: Icons.schedule,
                iconActiveColor: Color(0xFFEEC05C),
                text: 'Schedule',
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEEC05C),
                ),
              ),
              GButton(
                icon: Icons.wysiwyg,
                iconActiveColor: Color(0xFFEEC05C),
                text: 'Activities',
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEEC05C),
                ),
              ),
              GButton(
                icon: Icons.menu,
                iconActiveColor: Color(0xFFEEC05C),
                text: 'Menu',
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEEC05C),
                ),
              ),
            ],
          ),
        ));
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
          transition: Transition.fade,
          transitionDuration: const Duration(milliseconds: 500),
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    DateTime now = DateTime.now();
    String name = 'Người dùng';
    String greetingMessage = getGreetingMessage(now.hour, name);
    final uiProvider = Provider.of<UIProvider>(context);
    bool isDark = uiProvider.themeMode == ThemeMode.dark ||
        (uiProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                greetingMessage,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đoàn thể',
                  style: TextStyle(
                    fontSize: screenHeight * 0.03,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Bạn đang trong 3 đoàn thể'),
                SizedBox(height: screenHeight * 0.02),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(3, (index) {
                      // Determining the color based on odd or even index
                      Color cardColor = (index % 2 == 0)
                          ? Colors.lightBlue.shade100
                          : Colors.purple.shade100;

                      // List of organizations
                      final organizations = [
                        {
                          'title': 'Youth Group',
                          'membersCount': 5,
                        },
                        {
                          'title': 'Choir',
                          'membersCount': 8,
                        },
                        {
                          'title': 'Outreach Ministry',
                          'membersCount': 8,
                        },
                      ];

                      return OrganizationCard(
                        color: cardColor,
                        title: organizations[index]['title'] as String,
                        membersCount:
                            organizations[index]['membersCount'] as int,
                      );
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String getGreetingMessage(int hour, String name) {
    if (hour >= 3 && hour < 11) {
      return 'Chào buổi sáng, $name';
    } else if (hour >= 11 && hour < 16) {
      return 'Chào buổi trưa, $name';
    } else if (hour >= 16 && hour < 18) {
      return 'Chào buổi chiều, $name';
    } else {
      return 'Chào buổi tối, $name';
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

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    if (mounted) {
      setState(() {
        selectedDay = day;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('vi');
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final uiProvider = Provider.of<UIProvider>(context);
    bool isDark = uiProvider.themeMode == ThemeMode.dark ||
        (uiProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Column(
          children: [
            TableCalendar(
              locale: "vi",
              rowHeight: screenHeight * 0.05,
              focusedDay: focusedDay,
              firstDay: DateTime.utc(2020, 01, 01),
              lastDay: DateTime.utc(2040, 12, 31),
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarFormat: _calendarFormat,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Tháng',
                CalendarFormat.twoWeeks: '2 Tuần',
                CalendarFormat.week: 'Tuần',
              },
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

              // Format change handling

              // When the calendar header is tapped
              onHeaderTapped: (focusedDay) {
                if (mounted) {
                  setState(() {
                    selectedDay = DateTime.now();
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

  final List<String> organizations = [
    'Youth Group',
    'Choir',
    'Outreach Ministry',
    'Bible Study',
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
        centerTitle: true,
        title: Text(
          'Activities',
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
                  hint: Text("Choose your organization"),
                  value: selectedOrganization,
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                  iconSize: 30,
                  dropdownColor: Colors.white,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  items: organizations.map((String organization) {
                    return DropdownMenuItem<String>(
                      value: organization,
                      child: Row(
                        children: [
                          Icon(Icons.group, color: Colors.blue),
                          SizedBox(width: 10),
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
                          SizedBox(width: 8),
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
                          print(index);
                          print(
                              "Selected index: $selectedIndex"); // Debug output
                        });
                      },
                    );
                  },
                ).toList(),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
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
                onTap: () async {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
