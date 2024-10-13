import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shepherd_mo/pages/settings.dart';
import 'package:shepherd_mo/providers/provider.dart';
import 'package:shepherd_mo/widgets/profile_menu_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<String> _tabsRoutes = [
    '/home',
    '/schedule',
    '/notifications',
    '/menu',
  ];

  void _onTabTapped(int index) {
    if (_selectedIndex == index) {
      Get.offAllNamed(_getInitialRouteForTab(index), id: index);
    }
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(_selectedIndex,
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index; // Update selected index on swipe
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
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

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: List.generate(4, (index) => _buildNestedNavigator(index)),
      ),
      bottomNavigationBar: GNav(
        backgroundColor: const Color(0xFFEEC05C),
        color: isDark ? Colors.black : Colors.white,
        activeColor: Colors.blue,
        tabBackgroundColor: isDark ? Colors.black : Colors.grey.shade100,
        gap: screenWidth * 0.03,
        selectedIndex: _selectedIndex,
        onTabChange: _onTabTapped,
        padding: const EdgeInsets.all(16),
        tabs: const [
          GButton(
              icon: Icons.home,
              iconActiveColor: Color(0xFFEEC05C),
              text: 'Home',
              textStyle: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFFEEC05C))),
          GButton(
              icon: Icons.schedule,
              iconActiveColor: Color(0xFFEEC05C),
              text: 'Schedule',
              textStyle: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFFEEC05C))),
          GButton(
              icon: Icons.notifications,
              iconActiveColor: Color(0xFFEEC05C),
              text: 'Notification',
              textStyle: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFFEEC05C))),
          GButton(
              icon: Icons.menu,
              iconActiveColor: Color(0xFFEEC05C),
              text: 'Menu',
              textStyle: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFFEEC05C))),
        ],
      ),
    );
  }

  String _getInitialRouteForTab(int index) {
    switch (index) {
      case 0:
        return '/home';
      case 1:
        return '/schedule';
      case 2:
        return '/notifications';
      case 3:
        return '/menu';
      default:
        return '/home';
    }
  }

  Widget _buildNestedNavigator(int index) {
    return Navigator(
      key: Get.nestedKey(index),
      initialRoute: _tabsRoutes[index],
      onGenerateRoute: (RouteSettings settings) {
        Widget page;
        switch (settings.name) {
          case '/home':
            page = const HomeTab();
            break;
          case '/schedule':
            page = const ScheduleTab();
            break;
          case '/notifications':
            page = const NotificationTab();
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
    return const Scaffold();
  }
}

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({super.key});
  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class NotificationTab extends StatefulWidget {
  const NotificationTab({super.key});

  @override
  State<NotificationTab> createState() => _NotificationTabState();
}

class _NotificationTabState extends State<NotificationTab> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Menu', style: Theme.of(context).textTheme.headlineMedium),
        actions: const [],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(8),
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
              const SizedBox(height: 8),
              const Text('Name',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text('Email', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              SizedBox(
                width: 200,
                height: 50,
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
                      id: 3, transition: Transition.rightToLeftWithFade);
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
