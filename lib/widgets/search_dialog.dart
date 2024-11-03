import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class GroupListDialog extends StatefulWidget {
  final String apiToken;

  const GroupListDialog({super.key, required this.apiToken});

  @override
  _GroupListDialogState createState() => _GroupListDialogState();
}

class _GroupListDialogState extends State<GroupListDialog> {
  static const _pageSize = 5;
  final PagingController<int, Map<String, dynamic>> _pagingController =
      PagingController(firstPageKey: 1);
  String _searchText = ''; // Empty to show all items initially
  Timer? _debounce; // Timer for debouncing
  final List<Map<String, dynamic>> _selectedItems = []; // Store selected items

  @override
  void initState() {
    super.initState();

    // Start by loading all results initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pagingController.refresh();
    });

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await fetchSearchResults(
        searchText: _searchText,
        pageNumber: pageKey,
        pageSize: _pageSize,
        apiToken: widget.apiToken,
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

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _searchText = value;
          _pagingController.refresh(); // Safely refresh after build
        }
      });
    });
  }

  void _toggleSelection(Map<String, dynamic> item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item); // Deselect item
      } else {
        _selectedItems.add(item); // Select item
      }
    });
  }

  bool _isSelected(Map<String, dynamic> item) {
    return _selectedItems.contains(item);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _onSearchChanged, // Debounced search input
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300, // Limit height for the list within the dialog
              child: PagedListView<int, Map<String, dynamic>>(
                pagingController: _pagingController,
                builderDelegate:
                    PagedChildBuilderDelegate<Map<String, dynamic>>(
                  itemBuilder: (context, item, index) => ListTile(
                    title: Text(item['groupName'] ?? 'No name'),
                    subtitle: Text(item['description'] ?? 'No description'),
                    trailing: Icon(
                      _isSelected(item)
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: _isSelected(item) ? Colors.blue : null,
                    ),
                    onTap: () => _toggleSelection(item), // Toggle selection
                  ),
                  firstPageProgressIndicatorBuilder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  newPageProgressIndicatorBuilder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  noItemsFoundIndicatorBuilder: (context) => const Center(
                    child: Text("No results found."),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close without selection
                    },
                    child: const Text('Close'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop(_selectedItems); // Return selected items
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchSearchResults({
    required String searchText,
    required int pageNumber,
    required int pageSize,
    required String apiToken,
  }) async {
    final url = Uri.parse(
        'https://shepherd-api-bnh0fkamhzbkagg2.southeastasia-01.azurewebsites.net/api/group?SearchKey=$searchText&PageNumber=$pageNumber&PageSize=$pageSize');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $apiToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(data['result']);
      return results;
    } else {
      throw Exception('Failed to load search results');
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _debounce?.cancel(); // Cancel debounce timer if active
    super.dispose();
  }
}
