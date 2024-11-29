import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shepherd_mo/api/api_service.dart';
import 'package:shepherd_mo/models/notification.dart';
import 'package:shepherd_mo/widgets/empty_data.dart';
import 'package:shepherd_mo/widgets/end_of_line.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  static const _pageSize = 5;
  final PagingController<int, NotificationModel> _pagingController =
      PagingController(firstPageKey: 1, invisibleItemsThreshold: 1);
  final searchController = TextEditingController();
  final searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
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

  void _unfocus() {
    FocusScope.of(context).unfocus();
  }

  // Method to refresh the entire list
  Future<void> _refreshList() async {
    _pagingController.refresh(); // Refresh the PagingController
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(localizations.notification,
            style: Theme.of(context).textTheme.headlineMedium),
        backgroundColor: Colors.orange[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RefreshIndicator(
          displacement: 20,
          onRefresh: _refreshList, // Triggers the refresh method
          child: PagedListView<int, NotificationModel>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<NotificationModel>(
              itemBuilder: (context, item, index) => ListTile(
                title: Text(item.title ?? localizations.noData),
                subtitle: Text(item.content ?? localizations.noData),
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
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
