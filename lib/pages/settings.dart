import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:provider/provider.dart';
import 'package:shepherd_mo/providers/provider.dart';
import 'package:shepherd_mo/widgets/profile_menu_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _themeController = ValueNotifier<bool>(false);
  final _systemController = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UIProvider>(context);
    bool isDark = uiProvider.themeMode == ThemeMode.dark ||
        (uiProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
      ),
      body: ProfileMenuWidget(
        icon: Icons.dark_mode,
        iconColor: isDark ? Colors.white : Colors.black,
        onTap: () {
          _showBottomSheet(context);
        },
        title: 'Dark Mode',
        endIcon: false,
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer<UIProvider>(
        builder: (context, UIProvider notifier, child) {
          bool isSystemMode = notifier.themeMode == ThemeMode.system;
          bool isDark = notifier.themeMode == ThemeMode.dark ||
              (isSystemMode &&
                  MediaQuery.of(context).platformBrightness == Brightness.dark);

          _themeController.value = isDark;
          _systemController.value = isSystemMode;
          return Wrap(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    // Close the bottom sheet
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                title: const Text('Theme Mode'),
                trailing: AdvancedSwitch(
                  controller: _themeController,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.yellow,
                  activeChild: Text(
                    'Dark',
                    style: TextStyle(
                      fontSize: screenHeight * 0.02,
                    ),
                  ),
                  inactiveChild: Text(
                    'Light',
                    style: TextStyle(
                        color: Colors.black, fontSize: screenHeight * 0.02),
                  ),
                  initialValue: isDark,
                  borderRadius: BorderRadius.all(const Radius.circular(30)),
                  activeImage: const AssetImage('assets/images/dark.png'),
                  inactiveImage: const AssetImage('assets/images/light.png'),
                  width: 90.0,
                  height: 40.0,
                  enabled: !isSystemMode, // Disable when system mode is on
                  disabledOpacity: 0.5,
                  thumb: ValueListenableBuilder(
                    valueListenable: _themeController,
                    builder: (_, value, __) {
                      return CircleAvatar(
                        backgroundColor:
                            value ? Colors.blue.shade900 : Colors.yellowAccent,
                        child: Icon(value ? Icons.dark_mode : Icons.light_mode,
                            color: value ? Colors.white : Colors.black),
                      );
                    },
                  ),
                  onChanged: (value) {
                    if (!isSystemMode) {
                      notifier.setThemeMode(
                          value ? ThemeMode.dark : ThemeMode.light);
                    }
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('System Mode'),
                trailing: AdvancedSwitch(
                  controller: _systemController,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.grey,
                  activeChild: Text('On',
                      style: TextStyle(fontSize: screenHeight * 0.02)),
                  inactiveChild: Text('Off',
                      style: TextStyle(fontSize: screenHeight * 0.02)),
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  width: 90.0,
                  height: 40.0,
                  initialValue: isSystemMode,
                  thumb: ValueListenableBuilder(
                    valueListenable: _systemController,
                    builder: (_, value, __) {
                      return CircleAvatar(
                        backgroundColor:
                            value ? Colors.blue.shade900 : Colors.grey,
                        child: Icon(value ? Icons.check : Icons.close,
                            color: Colors.white),
                      );
                    },
                  ),
                  onChanged: (value) {
                    setState(() {
                      isSystemMode = value; // Update isSystemMode state
                    });
                    if (value) {
                      // Switch to system mode
                      notifier.setThemeMode(ThemeMode.system);
                      bool isDarkSystem =
                          MediaQuery.of(context).platformBrightness ==
                              Brightness.dark;
                      _themeController.value =
                          isDarkSystem; // Sync theme switch with system
                    } else {
                      // Switch to user-controlled mode
                      notifier.setThemeMode(_themeController.value
                          ? ThemeMode.dark
                          : ThemeMode.light);
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
