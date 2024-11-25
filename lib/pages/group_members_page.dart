import 'dart:async';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:shepherd_mo/api/api_service.dart';
import 'package:shepherd_mo/formatter/avatar.dart';
import 'package:shepherd_mo/models/group.dart';
import 'package:shepherd_mo/models/group_member.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shepherd_mo/providers/ui_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shepherd_mo/widgets/empty_data.dart';
import 'package:shepherd_mo/widgets/end_of_line.dart';

class GroupDetail extends StatefulWidget {
  final Group group;

  const GroupDetail({super.key, required this.group});

  @override
  _GroupDetailState createState() => _GroupDetailState();
}

class _GroupDetailState extends State<GroupDetail> {
  static const _pageSize = 5;
  final PagingController<int, GroupMember> _pagingController =
      PagingController(firstPageKey: 1, invisibleItemsThreshold: 1);

  String _searchText = '';
  bool _isAscending = false;
  String _sortBy = 'name';
  Timer? _debounce;
  bool _showButton = false;
  int orderBy = 0;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    _checkUserRole();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      ApiService apiService = ApiService();
      if (_sortBy == 'name') {
        _isAscending ? orderBy = 0 : orderBy = 1;
      } else if (_sortBy == 'role') {
        _isAscending ? orderBy = 10 : orderBy = 11;
      }

      final newItems = await apiService.fetchGroupMembers(
        searchKey: _searchText,
        pageNumber: pageKey,
        pageSize: _pageSize,
        groupId: widget.group.id,
        orderBy: orderBy.toString(),
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

  Future<void> _checkUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('userRole') ?? '';

    setState(() {
      _showButton = role == 'admin' || role == 'group_manager';
    });
  }

  Future<void> _refreshList() async {
    _pagingController.refresh();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchText = value;
        _pagingController.refresh();
      });
    });
  }

  void _onSortChanged(String sortBy) {
    setState(() {
      _sortBy = sortBy;
    });
    _refreshList();
  }

  void _toggleSortDirection() {
    setState(() {
      _isAscending = !_isAscending;
    });
    _refreshList();
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Admin Action"),
          content: const Text("This is a placeholder for admin actions."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final uiProvider = Provider.of<UIProvider>(context);
    bool isDark = uiProvider.themeMode == ThemeMode.dark ||
        (uiProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(localizations.details,
            style: Theme.of(context).textTheme.headlineMedium),
        backgroundColor: Colors.orange[800],
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.035), // Responsive padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                  width: screenWidth * 0.003,
                ),
              ),
              elevation: 1,
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.group.groupName,
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      widget.group.description,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: isDark ? Colors.grey.shade400 : Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      '${localizations.member}: ${widget.group.memberCount}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: isDark ? Colors.grey.shade400 : Colors.grey[600],
                      ),
                    ),
                    if (_showButton)
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: _showDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Admin Action",
                            style: TextStyle(fontSize: screenWidth * 0.035),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Container(
              padding: EdgeInsets.all(screenWidth * 0.03),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                  width: screenWidth * 0.003,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: localizations.search,
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.amber),
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade900 : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.01,
                          horizontal: screenWidth * 0.04,
                        ),
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  DropdownButton<String>(
                    alignment: Alignment.bottomCenter,
                    value: _sortBy,
                    items: [
                      DropdownMenuItem(
                        value: 'name',
                        child: Text(localizations.name),
                      ),
                      DropdownMenuItem(
                        value: 'role',
                        child: Text(localizations.role),
                      ),
                    ],
                    onChanged: (value) => _onSortChanged(value ?? 'name'),
                    style: TextStyle(
                      color: isDark ? Colors.amber[300] : Colors.amber[800],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Colors.amber[700],
                      size: screenWidth * 0.06,
                    ),
                    onPressed: _toggleSortDirection,
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshList,
                child: PagedListView<int, GroupMember>(
                  pagingController: _pagingController,
                  builderDelegate: PagedChildBuilderDelegate<GroupMember>(
                    itemBuilder: (context, item, index) => Container(
                      padding: EdgeInsets.all(screenWidth * 0.03),
                      margin:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.white,
                        border: Border.all(
                          color: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade400,
                          width: screenWidth * 0.002,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.2),
                            blurRadius: screenWidth * 0.02,
                            spreadRadius: screenWidth * 0.005,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                AvatarFormat().getRandomAvatarColor(),
                            radius: screenWidth * 0.055,
                            child: Text(
                              AvatarFormat()
                                  .getInitials(item.name, twoLetters: true),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name ?? localizations.noData,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.003),
                                Text(
                                  item.email ?? localizations.noData,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.grey.shade500
                                        : Colors.grey[700],
                                    fontSize: screenWidth * 0.03,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.03,
                                vertical: screenHeight * 0.005),
                            decoration: BoxDecoration(
                              color: item.groupRole == 'Thành viên'
                                  ? (isDark
                                      ? Colors.grey.shade500
                                      : Colors.grey
                                          .shade500) // Use white or dark grey for "Member"
                                  : (isDark
                                      ? Colors.amber.shade900
                                      : Colors.amber[
                                          100]), // Use amber color for non-members
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.groupRole ?? localizations.noData,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.bold,
                                color: item.groupRole == 'Thành viên'
                                    ? (isDark
                                        ? Colors.white
                                        : Colors
                                            .black) // Adjust text color based on background
                                    : (isDark
                                        ? Colors.white
                                        : Colors.amber[800]),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    firstPageProgressIndicatorBuilder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                    newPageProgressIndicatorBuilder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                    noItemsFoundIndicatorBuilder: (context) =>
                        _searchText.isNotEmpty
                            ? EmptyData(
                                noDataMessage: localizations.noResult,
                                message: localizations.godAlwaysByYourSide)
                            : EmptyData(
                                noDataMessage: localizations.noMember,
                                message: localizations.godAlwaysByYourSide),
                    noMoreItemsIndicatorBuilder: (_) => EndOfListWidget(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
