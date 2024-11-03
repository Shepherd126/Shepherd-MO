import 'package:flutter/material.dart';
import 'package:shepherd_mo/widgets/progressHUD.dart';

class SearchListDialog extends StatefulWidget {
  const SearchListDialog({super.key});

  @override
  _SearchListDialogState createState() => _SearchListDialogState();
}

class _SearchListDialogState extends State<SearchListDialog> {
  List<Map<String, dynamic>> _searchResults = [
    {"id": "1", 'name': 'Lễ Chúa Giáng Sinh', 'date': '2024-12-25'},
    {"id": "2", 'name': 'Lễ Các Thánh Nam Nữ', 'date': '2024-11-01'},
    {"id": "3", 'name': 'Lễ Đức Mẹ Vô Nhiễm Nguyên Tội', 'date': '2024-12-09'},
  ];
  bool isApiCallProcess = false;

  void _search(String searchText) async {
    setState(() {
      isApiCallProcess = true;
    });
    try {
      final results = await fetchSearchResults(searchText);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      print('Error fetching search results: $e');
    } finally {
      setState(() {
        isApiCallProcess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      inAsyncCall: isApiCallProcess,
      opacity: 0.3,
      child: _uiSetup(context),
    );
  }

  @override
  Widget _uiSetup(BuildContext context) {
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
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _search(value);
                } else {
                  setState(() {
                    _searchResults.clear();
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            _searchResults.isEmpty
                ? const Text("No results found.")
                : SizedBox(
                    height:
                        300, // Set a height limit for the list within the dialog
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final item = _searchResults[index];
                        return ListTile(
                          title: Text(item['name'] ?? 'No name'),
                          subtitle: Text(item['date'] ?? 'No date'),
                          onTap: () => Navigator.of(context).pop(item),
                        );
                      },
                    ),
                  ),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchSearchResults(
      String searchText) async {
    // Simulating a delay for network request
    await Future.delayed(const Duration(seconds: 0));

    // Filtering items based on the search text
    return _searchResults.where((item) {
      return item['name']!.toLowerCase().contains(searchText.toLowerCase());
    }).toList();
  }
}
