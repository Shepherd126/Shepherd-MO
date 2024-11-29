import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shepherd_mo/controller/controller.dart';
import 'package:shepherd_mo/pages/leader/request_page.dart';
import 'package:shepherd_mo/pages/notification_page.dart';
import 'package:shepherd_mo/providers/ui_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double screenWidth;
  final double screenHeight;

  const CustomAppBar({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UIProvider>(context);
    final authorizationController = Get.find<AuthorizationController>();

    bool isDark = uiProvider.themeMode == ThemeMode.dark ||
        (uiProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    return AppBar(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade300,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      leading: Obx(() {
        return authorizationController.isAuthorized.value ||
                authorizationController.isLeader.value
            ? PopupMenuButton<int>(
                position: PopupMenuPosition.under,
                icon: Icon(
                  Icons.menu,
                  size: screenWidth * 0.075,
                  color: Colors.grey[700],
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: const [
                        Icon(Icons.create, color: Colors.grey),
                        SizedBox(width: 10),
                        Text("Create Request"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                      value: 2,
                      child: Row(
                        children: const [
                          Icon(Icons.request_page, color: Colors.grey),
                          SizedBox(width: 10),
                          Text("List Request"),
                        ],
                      ),
                      onTap: () {
                        Get.to(RequestList(),
                            transition: Transition.rightToLeftWithFade);
                      }),
                ],
                onSelected: (value) {
                  // Handle menu item selection based on value
                },
              )
            : SizedBox.shrink();
      }),
      actions: [
        // Notification Button
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Stack(
            children: <Widget>[
              SizedBox(
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
                child: IconButton(
                  onPressed: () {
                    // Handle notification button press
                    Get.to(() => NotificationPage(),
                        transition: Transition.rightToLeftWithFade);
                  },
                  icon: Icon(
                    Icons.notifications_none,
                    size: screenWidth * 0.075,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.01),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],

      // Shepherd Logo and Title with Gradient Text
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
            child: Image.asset(
              'assets/images/shepherd.png',
              height: screenHeight * 0.04,
              fit: BoxFit.contain,
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange.shade900,
                Colors.orange.shade600,
              ],
              stops: const [0.2, 0.8],
            ).createShader(bounds),
            child: Text(
              'Shepherd',
              style: TextStyle(
                fontSize: screenWidth * 0.08,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
