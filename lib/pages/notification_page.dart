import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:shepherd_mo/api/api_service.dart';
import 'package:shepherd_mo/constant/constant.dart';
import 'package:shepherd_mo/controller/controller.dart';
import 'package:shepherd_mo/models/notification.dart';
import 'package:shepherd_mo/providers/ui_provider.dart';
import 'package:shepherd_mo/widgets/empty_data.dart';
import 'package:shepherd_mo/widgets/end_of_line.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shepherd_mo/widgets/notification_card.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  static const _pageSize = 10;
  final PagingController<int, NotificationModel> _pagingController =
      PagingController(firstPageKey: 1, invisibleItemsThreshold: 1);
  final NotificationController notificationController =
      Get.find<NotificationController>();

  @override
  void initState() {
    super.initState();

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    notificationController.fetchUnreadCount();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      ApiService apiService = ApiService();

      final newItems = await apiService.fetchNotifications(
        searchKey: null,
        pageNumber: pageKey,
        pageSize: _pageSize,
      );

      final isLastPage = newItems.length < _pageSize;

      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (e) {
      _pagingController.error = e;
    }
  }

  // Method to refresh the entire list
  Future<void> _refreshList() async {
    _pagingController.refresh(); // Refresh the PagingController
    notificationController.fetchUnreadCount();
  }

  void _markAllAsRead() async {
    // Add your "mark all as read" logic here
    final apiService = ApiService();
    await apiService.readAllNoti();
    notificationController.fetchUnreadCount();

    setState(() {
      // Update the list locally (this depends on how your notification data is structured)
      for (var notification in _pagingController.itemList!) {
        notification.isRead = true; // Assuming there's an 'isRead' property
      }
    });
    print('All notifications marked as read');
  }

  // Delete notification
  void _deleteNotification(NotificationModel notification) {
    setState(() {
      _pagingController.itemList?.remove(notification);
    });
    ApiService().deleteNoti(notification.id); // Call API to delete
    notificationController.fetchUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final localizations = AppLocalizations.of(context)!;
    final uiProvider = Provider.of<UIProvider>(context);
    bool isDark = uiProvider.themeMode == ThemeMode.dark ||
        (uiProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          localizations.notification,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.black,
              ),
        ),
        iconTheme: IconThemeData(
          color: Colors.black, // Set leading icon color explicitly
        ),
        backgroundColor: Const.primaryGoldenColor,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // Handle menu action here (e.g., show a menu, etc.)
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                builder: (context) => Consumer<UIProvider>(
                  builder: (context, UIProvider notifier, child) {
                    bool isDark = notifier.themeMode == ThemeMode.dark ||
                        (MediaQuery.of(context).platformBrightness ==
                            Brightness.dark);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade300,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                        // Mark as Read
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade300,
                            child: Icon(Icons.mark_chat_read_rounded,
                                color: Colors.blue),
                          ),
                          title: Text(localizations.markAllAsRead),
                          onTap: () async {
                            _markAllAsRead();
                            Navigator.pop(context); // Close the bottom sheet
                          },
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RefreshIndicator(
          displacement: 20,
          onRefresh: _refreshList, // Triggers the refresh method
          child: PagedListView<int, NotificationModel>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<NotificationModel>(
              itemBuilder: (context, item, index) => NotificationCard(
                notification: item,
                onDelete: _deleteNotification,
              ),
              firstPageProgressIndicatorBuilder: (_) =>
                  const Center(child: CircularProgressIndicator()),
              newPageProgressIndicatorBuilder: (_) =>
                  const Center(child: CircularProgressIndicator()),
              noItemsFoundIndicatorBuilder: (context) => EmptyData(
                noDataMessage: localizations.noNotification,
                message: localizations.wellDoneServant,
              ),
              noMoreItemsIndicatorBuilder: (_) => EndOfListWidget(),
              animateTransitions: true,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    notificationController.closeNotificationPage();
    super.dispose();
  }
}
